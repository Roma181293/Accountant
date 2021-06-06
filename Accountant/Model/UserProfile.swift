//
//  UserProfile.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2021.
//

import Foundation
class UserProfile {
    
    static func setExchangeRate(_ currencyHistoricalData : CurrencyHistoricalDataProtocol) {
        let encoder = JSONEncoder()
        let defaults = UserDefaults.standard
        if let currencyHistoricalDataNB = currencyHistoricalData as? CurrencyHistoricalDataNB , let encoded = try? encoder.encode(currencyHistoricalDataNB) {
            defaults.set(encoded, forKey: "currencyHistoricalData")
            print("save NB")
        }
        if let currencyHistoricalDataPB = currencyHistoricalData as? CurrencyHistoricalDataPB, let encoded = try? encoder.encode(currencyHistoricalDataPB) {
            defaults.set(encoded, forKey: "currencyHistoricalData")
            print("save PB")
        }
    }
    
    static func getLastExchangeRate() -> CurrencyHistoricalDataProtocol? {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "currencyHistoricalData") as? Data {
            let decoder = JSONDecoder()
            if let currencyHistoricalDataPB = try? decoder.decode(CurrencyHistoricalDataPB.self, from: data) {
                print("read PB")
                return currencyHistoricalDataPB
            }
            else if let currencyHistoricalDataNB = try? decoder.decode(CurrencyHistoricalDataNB.self, from: data) {
                print("read NB")
                return currencyHistoricalDataNB
            }
        }
        return nil
    }
    
    
    static func setDateOfLastChangesInDB(_ date : Date){
        let defaults = UserDefaults.standard
        defaults.set(date, forKey: "dateOfLastChangesInDB")
    }
    
    static func getDateOfLastChangesInDB() -> Date? {
        let defaults = UserDefaults.standard
        if let lastEditingTransactionDate = defaults.object(forKey: "dateOfLastChangesInDB") as? Date {
            return lastEditingTransactionDate
        }
        else {
            return nil
        }
    }
    static func firstAppLaunch() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "appLaunchedBefore")
    }
    
    static func isAppLaunchedBefore() -> Bool{
        if let launchedBefore = UserDefaults.standard.object(forKey: "appLaunchedBefore") as? Bool {
            return launchedBefore
        }
        else {
            return false
        }
    }
    
    static func setUserAuth(_ authType: AuthType) {
        let defaults = UserDefaults.standard
        defaults.set(authType.rawValue, forKey: "userAuthType")
    }
    
    static func getUserAuth() -> AuthType {
        if let userAuthType = UserDefaults.standard.object(forKey: "userAuthType") as? Int {
            if userAuthType == AuthType.bioAuth.rawValue {
                return AuthType.bioAuth
            }
            else if userAuthType == AuthType.none.rawValue {
                return AuthType.none
            }
        }
        return AuthType.none
    }
    
    static func setAppBecomeBackgroundDate(_ date: Date?) {
        if getAppBecomeBackgroundDate() == nil {
            let defaults = UserDefaults.standard
            defaults.set(date, forKey: "appBecomeBackgroundDate")
        }
        else if date == nil {
            let defaults = UserDefaults.standard
            defaults.set(nil, forKey: "appBecomeBackgroundDate")
        }
    }
    
    static func getAppBecomeBackgroundDate() -> Date? {
        guard let date = UserDefaults.standard.object(forKey: "appBecomeBackgroundDate") as? Date else {return nil}
        return date
    }
    
    static func setAccountingStartDate(_ date: Date) {
        if getAppBecomeBackgroundDate() == nil {
            let defaults = UserDefaults.standard
            defaults.set(date, forKey: "appAccountingStartDate")
        }
    }
    
    static func getAccountingStartDate() -> Date? {
        guard let date = UserDefaults.standard.object(forKey: "appAccountingStartDate") as? Date else {return nil}
        return date
    }
    
    static func autoCreateBudgetsMethodDidWorked() {
        UserDefaults.standard.set(Date(), forKey: "autoCreateBudgetsMethodDidWorked")
    }
    
    static func lastGereratedBudgetsDate() -> Date? {
        guard let date = UserDefaults.standard.object(forKey: "autoCreateBudgetsMethodDidWorked") as? Date else {return nil}
        return date
    }
    
    
    static func setEntitlement(_ entitlement: Entitlement) {
            let defaults = UserDefaults.standard
        defaults.set(entitlement.name.rawValue, forKey: "Subscriprion.entitlement")
        defaults.set(entitlement.expirationDate, forKey: "Subscriprion.expirationDate")
        defaults.set(entitlement.lastUpdate, forKey: "Subscriprion.lastUpdate")
    }
    
    static func getEntitlement() -> Entitlement? {
        guard let entitlementString = UserDefaults.standard.object(forKey: "Subscriprion.entitlement") as? String,
              let lastUpdate = UserDefaults.standard.object(forKey: "Subscriprion.lastUpdate") as? Date else {return nil}
        
        guard let expirationDate = UserDefaults.standard.object(forKey: "Subscriprion.expirationDate") as? Date else {
            let name: EntitlementPacketName
            switch entitlementString {
            case "pro":
                name = .pro
            default:
                name = .none
            }
            
            return Entitlement(name: name, expirationDate: nil, lastUpdate: lastUpdate)
        }
        
        
        let name: EntitlementPacketName
        switch entitlementString {
        case "pro":
            name = .pro
        default:
            name = .none
        }
        return Entitlement(name: name, expirationDate: expirationDate, lastUpdate: lastUpdate)
    }
    
    //MARK:- ADD AND OFFER COUNTERS
    enum AppViews: String{
        case transactionEditor
        case configureAnalytics
        case moneyAccounts
    }
    
    enum PreContentForUserWOSubscription {
        case add
        case offer
        case none
    }
    
    
    static func viewDidOpen(view: AppViews) {
        var count = 0
        if let storedCount = UserDefaults.standard.object(forKey: "\(view.rawValue)ViewOpenCount") as? Int{
           count = storedCount
        }
        UserDefaults.standard.set(count+1, forKey: "\(view.rawValue)ViewOpenCount")
    }
    
    static func needShowAddForView(_ view: AppViews)->Bool {
        guard let count = UserDefaults.standard.object(forKey: "\(view.rawValue)ViewOpenCount") as? Int else {return false}
        
//        switch view {
//        case .transaction:
//            if count % 2 == 0 {
//                return true
//            }
//            return false
//        case .analytics:
//            if count % 2 == 0 {
//                return true
//            }
//            return false
//        case .moneyAccounts:
//            if count % 2 == 0 {
//                return true
//            }
//            return false
//        }
        
        
        if count % 2 == 0 {
            return true
        }
        return false
    }
    
    static func needShowOfferForView(_ view: AppViews)->Bool {
        guard let count = UserDefaults.standard.object(forKey: "\(view.rawValue)ViewOpenCount") as? Int else {return false}
        if count % 3 == 0 {
            return true
        }
        return false
    }
    
    static func whatPreContentShowInView(_ view: AppViews) -> PreContentForUserWOSubscription {
        viewDidOpen(view: view)
        guard let count = UserDefaults.standard.object(forKey: "\(view.rawValue)ViewOpenCount") as? Int else {return .none}
        
        switch view {
        case .transactionEditor:
            if count % 3 == 0 {
                return .add
            }
            else if count % 4 == 0 {
                return .offer
            }
            return .none
        case .moneyAccounts:
            return .none
        case .configureAnalytics:
            if count % 2 == 0 {
                return .add
            }
            return .offer
        }
    }
}
