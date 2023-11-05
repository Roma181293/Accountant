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
        let environment = CoreDataStack.shared.currentEnvironment
        let defaults = UserDefaults.standard
        defaults.set(String(NSLocalizedString(accountName.rawValue, comment: "")),
                     forKey: accountName.rawValue+environment.rawValue)
    }

    class func createAllLocalizedAccountName() {
        for item in BaseAccounts.allCases {
            createLocalizedAccountName(item)
        }
    }

    class func getLocalizedName(_ accountName: BaseAccounts) -> String {
        let environment = CoreDataStack.shared.currentEnvironment
        if let name = UserDefaults.standard.object(forKey: accountName.rawValue + environment.rawValue) as? String {
            return name
        } else {
            return accountName.rawValue
        }
    }
}
