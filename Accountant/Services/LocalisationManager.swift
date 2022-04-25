//
//  AccountsLocalisationManager.swift
//  Accounting
//
//  Created by Roman Topchii on 22.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

class LocalisationManager {

    class func createLocalizedAccountName(_ accountName: BaseAccounts) {
        var environment = Environment.prod
        if let environmentValue = CoreDataStack.shared.activeEnviroment() {
            environment = environmentValue
        }
        let defaults = UserDefaults.standard
        defaults.set(String(NSLocalizedString(accountName.rawValue, comment: "")),
                     forKey: accountName.rawValue+environment.rawValue)
    }

    static func createAllLocalizedAccountName() {
        for item in BaseAccounts.allCases {
            createLocalizedAccountName(item)
        }
    }

    static func getLocalizedName(_ accountName: BaseAccounts) -> String {
        var environment = Environment.prod
        if let environmentValue = CoreDataStack.shared.activeEnviroment() {
            environment = environmentValue
        }
        if let name = UserDefaults.standard.object(forKey: accountName.rawValue+environment.rawValue) as? String {
            return name
        } else {
            return accountName.rawValue
        }
    }
}
