//
//  AccessCheckManager.swift
//  Accountant
//
//  Created by Roman Topchii on 09.09.2021.
//

import Foundation


//ACCOUNTING-45 This class manage when user can perform some kind of action in UI
class AccessCheckManager {
    
    static func checkUserAccessToCreateSubAccountForSelected(account : Account?, isUserHasPaidAccess: Bool, environment: Environment) -> Bool {
        print(environment)
        if environment == .test ||
            (environment == .prod && (isUserHasPaidAccess || (isUserHasPaidAccess == false && (account == nil || account?.level == 0)))) {
            return true
        }
        return false
    }
    
    static func checkUserAccessToHideAccount(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || (environment == .prod && isUserHasPaidAccess == true){
            return true
        }
        return false
    }
    
    static func checkUserAccessToCreateAccountInNotAccountingCurrency(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || (environment == .prod && isUserHasPaidAccess == true){
            return true
        }
        return false
    }
    
    static func checkUserAccessToImportExportEntities(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || (environment == .prod && isUserHasPaidAccess == true){
            return true
        }
        return false
    }
}
