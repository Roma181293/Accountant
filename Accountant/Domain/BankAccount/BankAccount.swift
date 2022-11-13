//
//  BankAccount.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation
import CoreData

final class BankAccount: NSManagedObject {

    @NSManaged public var id: UUID
    @NSManaged public var externalId: String?
    @NSManaged public var active: Bool
    @NSManaged public var bin: Int16
    @NSManaged public var iban: String?
    @NSManaged public var lastLoadDate: Date?
    @NSManaged public var lastTransactionDate: Date?
    @NSManaged public var locked: Bool
    @NSManaged public var strBin: String?
    @NSManaged public var account: Account?
    @NSManaged public var userBankProfile: UserBankProfile?

    convenience init(userBankProfile: UserBankProfile, iban: String?, strBin: String?, bin: Int16?,
                     externalId: String?, lastTransactionDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.active = true
        self.iban = iban
        self.strBin = strBin
        self.bin = bin ?? 0
        self.externalId = externalId
        self.id = UUID()
        self.locked = false // semophore  true = do not load statement data
        self.userBankProfile = userBankProfile
        let calendar = Calendar.current
        self.lastTransactionDate = lastTransactionDate // calendar.date(byAdding: .day, value: -90, to: Date())!
        self.lastLoadDate = calendar.date(byAdding: .second, value: -60, to: lastTransactionDate)!
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BankAccount> {
        return NSFetchRequest<BankAccount>(entityName: "BankAccount")
    }
}
