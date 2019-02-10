
import UIKit
import Alamofire
import SwiftyJSON
import BRYXBanner


class MainTableViewController: UITableViewController {
    
    var records: [Record] = [];
    var recordsCount = 0;
    
    var source: String = "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2018";
    
    private func loadData() {
        AF.request(self.source, method: .get).responseJSON { response in
            guard response.result.isSuccess,
                let value = response.result.value else {
                    self.showNotificationError(title: "Error", subtitle: "Error while downloading data")
                    return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.records = (JSON(value)["entries"].array?.map { json in
                Record(
                    id: json["id"].intValue,
                    message: json["message"].stringValue,
                    name: json["name"].stringValue,
                    timestamp: dateFormatter.date(from: json["timestamp"].stringValue)
                )
                })!
            self.records = self.records.filter{ $0.timestamp != nil };
            self.records = self.records.sorted(by: {($0.timestamp!).compare($1.timestamp!) == .orderedDescending})
            self.tableView.reloadData();
            let difference = self.records.count - self.recordsCount;
            if (difference > 0) {
                self.showNotificationSuccess(title: difference.description + " new messages", subtitle: nil)
            } else {
                self.showNotificationSuccess(title: "No new messages", subtitle: nil)
            }
            self.recordsCount = self.records.count;
        };
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData();
    }
    
    @IBAction func refreshData(_ sender: Any) {
        loadData();
    }
    
    @IBAction func addMessage(_ sender: Any) {
        let alertController = UIAlertController(title: "New message", message: "Please state your name ad message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        })
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            let parameters: [String: String] = [
                "name": name!,
                "message": message!
            ];
            AF.request(self.source, method: .post, parameters: parameters).responseJSON { response in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        self.showNotificationError(title: "Error", subtitle: "Error while downloading data")
                        return
                }
                let result = JSON(value)["result"];
                if (result == "success") {
                    self.showNotificationSuccess(title: "Success", subtitle: "Message has been sent successfully")
                }
                
            };
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.records.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoutboxItem", for: indexPath)
        if indexPath.section == 0 {
            let record = self.records[indexPath.row]
            let message = record.message;
            let sender = record.name;
            let timestamp = record.timestamp!
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: timestamp, to: Date())
            let metadata = "by \(sender), \(components.hour!) hour(s), \(components.minute!) minute(s) and \(components.second!) second(s) ago"
            cell.textLabel!.text = message
            cell.detailTextLabel!.text = metadata
        }
        return cell
    }
    
    private func showNotificationSuccess(title: String, subtitle: String?) {
        let banner = Banner(title: title, subtitle: subtitle, image: nil, backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
        banner.dismissesOnTap = true
        banner.show(duration: 2.0)
    }
    
    private func showNotificationError(title: String, subtitle: String?) {
        let banner = Banner(title: title, subtitle: subtitle, image: nil, backgroundColor: UIColor(red:200.0/255.0, green:0/255.0, blue:0.0/255.0, alpha:1.000))
        banner.dismissesOnTap = true
        banner.show(duration: 2.0)
    }
    
    
}
