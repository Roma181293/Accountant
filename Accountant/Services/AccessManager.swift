//
//  AccessManager.swift
//  Accountant
//
//  Created by Roman Topchii on 09.09.2021.
//

import Foundation

class AccessManager {
    static func canCreateSubAccountFor(account: Account?, isUserHasPaidAccess: Bool, environment: Environment) -> Bool {
        print(environment)
        if environment == .test ||
            (environment == .prod && (isUserHasPaidAccess || (isUserHasPaidAccess == false
                                                              && account?.directChildrenList.count ?? 15 < 15
                                                              && (account == nil || account?.level == 0
                                                                  || account?.level == 1)))) {
            return true
        }
        return false
    }

    static func canHideAccount(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }

    static func canSwitchingAppToMultiItemMode(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }

    static func canCreateAccountInNonAccountingCurrency(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }

    static func canImportExportEntities(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }
}
