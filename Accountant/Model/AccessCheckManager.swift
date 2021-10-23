//
//  AccessCheckManager.swift
//  Accountant
//
//  Created by Roman Topchii on 09.09.2021.
//

import Foundation
import CoreData


//ACCOUNTING-45 This class manage when user can perform some kind of action in UI
class AccessCheckManager {
    
    static func checkUserAccessToCreateSubAccountForSelected(account : Account?, isUserHasPaidAccess: Bool, environment: Environment) -> Bool {
        print(environment)
        if environment == .test ||
            (environment == .prod && (isUserHasPaidAccess || (isUserHasPaidAccess == false && account?.directChildren?.count ?? 15 < 15 && (account == nil || account?.level == 0 || account?.level == 1)))) {
            return true
        }
        return false
        
        
        
//        print(environment)
//        if environment == .test ||
//            (environment == .prod && (isUserHasPaidAccess || (isUserHasPaidAccess == false && account?.directChildren?.count ?? 10 < 10 && (account == nil || account?.level == 0)))) {
//            return true
//        }
//        return false
    }
    
    static func checkUserAccessToHideAccount(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }
    
    static func checkUserAccessToSwitchingAppToMultiItemMode(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }
    
    static func checkUserAccessToCreateAccountInNotAccountingCurrency(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }
    
    static func checkUserAccessToCreateAccountInCurrency(currency: Currency?, environment: Environment, isUserHasPaidAccess: Bool, context: NSManagedObjectContext) -> Bool {
        
        guard let accountingCurrency = CurrencyManager.getAccountingCurrency(context: context) else {return false}
            
        if environment == .test || (environment == .prod && (isUserHasPaidAccess || (isUserHasPaidAccess == false && (currency == accountingCurrency || currency == nil)))) {
            
            return true
        }
        return false
    }
    
    static func checkUserAccessToImportExportEntities(environment: Environment, isUserHasPaidAccess: Bool) -> Bool {
        if environment == .test || isUserHasPaidAccess == true {
            return true
        }
        return false
    }
}
