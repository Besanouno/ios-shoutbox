import Foundation

class  Record {
    
    init(id: Int, message: String, name:String, timestamp:Date?) {
        self.id = id;
        self.message = message;
        self.name = name;
        self.timestamp = timestamp;
    }
    
    var id: Int = 0
    var message: String = ""
    var name: String = ""
    var timestamp: Date?
    
}
