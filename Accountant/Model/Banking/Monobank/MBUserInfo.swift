//
//  MBUserInfo.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation
import CoreData

struct MBUserInfo:Codable {
    let clientId: String
    let name: String
    let webHookUrl: String
    let permissions: String
    let accounts: [MBAccountInfo]
    
    func isExists(context: NSManagedObjectContext) -> Bool {
        return !UserBankProfileManager.isFreeExternalId(clientId, context: context)
    }
    
    func getUBP(conetxt: NSManagedObjectContext) -> UserBankProfile? {
        return UserBankProfileManager.getUBP(clientId, context: conetxt)
    }
}
