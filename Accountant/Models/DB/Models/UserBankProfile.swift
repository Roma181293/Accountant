//
//  UserBankProfile.swift
//  Accountant
//
//  Created by Roman Topchii on 28.11.2021.
//

import Foundation
import CoreData

final class UserBankProfile: NSManagedObject {

    @NSManaged public var id: UUID?
    @NSManaged public var externalId: String?
    @NSManaged public var name: String?
    @NSManaged public var active: Bool
    @NSManaged public var xToken: String?
    @NSManaged public var bankAccounts: Set<BankAccount>
    @NSManaged public var keeper: Keeper?

    convenience init(name: String, externalId: String?, keeper: Keeper, xToken: String,
                     context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.active = true
        self.xToken = xToken
        self.id = UUID()
        self.externalId = externalId
        self.keeper = keeper
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserBankProfile> {
        return NSFetchRequest<UserBankProfile>(entityName: "UserBankProfile")
    }
}
