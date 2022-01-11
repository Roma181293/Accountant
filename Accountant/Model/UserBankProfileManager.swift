//
//  UserBankProfileManager.swift
//  Accountant
//
//  Created by Roman Topchii on 28.11.2021.
//

import Foundation
import CoreData


class UserBankProfileManager {
    
    static func isFreeId(_ id: String?, context: NSManagedObjectContext) -> Bool {
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "id = %@", id as! CVarArg)
        
        if let ba = try? context.fetch(userBankProfileFetchRequest) as? [UserBankProfile], ba.isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
//    static func createMonoBankUBP(_ mbui: MBUserInfo, xToken: String, context: NSManagedObjectContext) throws -> UserBankProfile {
//        guard isFreeId(mbui.clientId, context: context) else {throw UserBankProfileError.alreadyExist}
//
//        let ubp = UserBankProfile(context: context)
//        ubp.name = mbui.name
//        ubp.xToken = xToken
//        ubp.id = mbui.clientId
//        ubp.keeper = try? KeeperManager.getKeeperForName(NSLocalizedString("Monobank", comment: ""), context: context)
////        for item in mbui.accounts{
////            BankAccountManager.createMBBankAccount(item, userBankProfile: ubp, context: context)
////        }
//        return ubp
//    }
    
    static func getUBP(_ id: String?, context: NSManagedObjectContext) -> UserBankProfile? {
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "id = %@", id as! CVarArg)
        
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
        userBankProfileFetchRequest.predicate = NSPredicate(format: "id = %@", mbui.clientId as! CVarArg)
        
        if let ubps = try? context.fetch(userBankProfileFetchRequest) as? [UserBankProfile], ubps.isEmpty == false {
            let ubp = ubps.last!
            ubp.xToken = xToken
            return ubp
        }
        else {
            let ubp = UserBankProfile(context: context)
            ubp.name = mbui.name
            ubp.xToken = xToken
            ubp.id = mbui.clientId
            ubp.keeper = try? KeeperManager.getKeeperForName(NSLocalizedString("Monobank", comment: ""), context: context)
            return ubp
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


