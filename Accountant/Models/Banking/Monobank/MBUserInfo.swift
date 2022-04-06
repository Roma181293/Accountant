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
        return !UserBankProfile.isFreeExternalId(clientId, context: context)
    }
    
    func getUBP(conetxt: NSManagedObjectContext) -> UserBankProfile? {
        return UserBankProfile.getUBP(clientId, context: conetxt)
    }
}
