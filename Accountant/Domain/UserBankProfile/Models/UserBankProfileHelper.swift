//
//  UserBankProfileHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class UserBankProfileHelper {
    class func isFreeExternalId(_ externalId: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = UserBankProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.UseBankProfile.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.UseBankProfile.externalId.rawValue) = %@", externalId as CVarArg)
        if let count = try? context.count(for: fetchRequest), count == 0 {
            return true
        } else {
            return false
        }
    }

    class func getUBP(_ externalId: String, context: NSManagedObjectContext) -> UserBankProfile? {
        let fetchRequest = UserBankProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.UseBankProfile.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.UseBankProfile.externalId.rawValue) = %@", externalId)
        if let ubps = try? context.fetch(fetchRequest), !ubps.isEmpty {
            return ubps.last
        } else {
            return nil
        }
    }

    class func getOrCreateMonoBankUBP(_ mbui: MBUserInfo, xToken: String,
                                      context: NSManagedObjectContext) throws -> UserBankProfile {
        let fetchRequest = UserBankProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.UseBankProfile.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.UseBankProfile.externalId.rawValue) = %@", mbui.clientId)
        
        if let ubps = try? context.fetch(fetchRequest), ubps.isEmpty == false {
            let ubp = ubps.last!
            ubp.xToken = xToken
            return ubp
        } else {
            // can be forced unwrapped coz this method shouldnt return error
            let keeper = try KeeperHelper.getKeeperForName(NSLocalizedString("Monobank", comment: ""),
                                                           context: context)!
            return UserBankProfile(name: mbui.name, externalId: mbui.clientId, keeper: keeper, xToken: xToken,
                                   context: context)
        }
    }
}
