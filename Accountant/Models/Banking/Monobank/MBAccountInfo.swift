//
//  MBAccountInfo.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation
import CoreData

struct MBAccountInfo: Codable {
    let id: String
    let sendId: String
    let balance: Int
    let creditLimit: Int
    let type: String
    let maskedPan: [String]
    let currencyCode: Int16
    let cashbackType: String
    let iban: String
    
    func getCurrency(context: NSManagedObjectContext) -> Currency? {
        return try? Currency.getCurrencyForISO4217(currencyCode, context: context)
    }
    
    func isExists(context: NSManagedObjectContext) -> Bool {
        return !BankAccount.isFreeExternalId(id, context: context)
    }
}
