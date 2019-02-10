//
//  StringExtension.swift
//  Lab2_TemplateApp
//
//  Created by marcinox on 10/02/2019.
//  Copyright © 2019 KIS AGH. All rights reserved.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
