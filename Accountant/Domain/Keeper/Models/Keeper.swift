//
//  Keeper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import Foundation
import CoreData

final class Keeper: BaseEntity {

    @objc enum TypeEnum: Int16 {
        case cash = 0
        case bank = 1
        case person = 2

        func toEmoji() -> String {
            switch self {
            case .cash: return "💸"
            case .bank: return "🏦"
            case .person: return "🧒"
            }
        }
    }

    @NSManaged public var name: String
    @NSManaged public var type: TypeEnum
    @NSManaged public var accounts: Set<Account>!
    @NSManaged public var userBankProfiles: Set<UserBankProfile>!

    convenience init(name: String, type: Keeper.TypeEnum, createdByUser: Bool = true, createDate: Date = Date(),
                     context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.name = name
        self.type = type
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Keeper> {
        return NSFetchRequest<Keeper>(entityName: "Keeper")
    }
}
