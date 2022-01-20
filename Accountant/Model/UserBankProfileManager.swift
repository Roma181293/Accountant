//
//  UserBankProfileManager.swift
//  Accountant
//
//  Created by Roman Topchii on 28.11.2021.
//

import Foundation
import CoreData


class UserBankProfileManager {
    
    static func isFreeExternalId(_ externalId: String?, context: NSManagedObjectContext) -> Bool {
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "externalId = %@", externalId as! CVarArg)
        
        if let ba = try? context.fetch(userBankProfileFetchRequest) as? [UserBankProfile], ba.isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    static func getUBP(_ externalId: String?, context: NSManagedObjectContext) -> UserBankProfile? {
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "externalId = %@", externalId as! CVarArg)
        
        if let ubps = try? context.fetch(userBankProfileFetchRequest) as? [UserBankProfile], !ubps.isEmpty {
            print(#function, "ubps.count", ubps.count)
            
            let ubp = ubps.last!
            return ubp
        }
        else {
            return nil
        }
    }
    
    static func getOrCreateMonoBankUBP(_ mbui: MBUserInfo, xToken: String, context: NSManagedObjectContext) -> UserBankProfile {
        
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "externalId = %@", mbui.clientId as! CVarArg)
        
        if let ubps = try? context.fetch(userBankProfileFetchRequest) as [UserBankProfile], ubps.isEmpty == false {
            let ubp = ubps.last!
            ubp.xToken = xToken
            return ubp
        }
        else {
            let ubp = UserBankProfile(context: context)
            ubp.name = mbui.name
            ubp.active = true
            ubp.xToken = xToken
            ubp.id = UUID()
            ubp.externalId = mbui.clientId
            ubp.keeper = try? KeeperManager.getKeeperForName(NSLocalizedString("Monobank", comment: ""), context: context)
            return ubp
        }
    }
    
    func changeActiveStatusFor(_ ubp: UserBankProfile, context: NSManagedObjectContext) {
        if ubp.active {
            ubp.active = false
            (ubp.bankAccounts?.allObjects as! [BankAccount]).forEach({
                $0.active = false
            })
        }
        else {
            ubp.active = true
        }
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllUBP(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let fetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let ubp = try context.fetch(fetchRequest)
        ubp.forEach({
            context.delete($0)
        })
    }
}


