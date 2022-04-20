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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Keeper> {
        return NSFetchRequest<Keeper>(entityName: "Keeper")
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

    var accountsList: [Account] {
        return Array(accounts)
    }

    var userBankProfilesList: [UserBankProfile] {
        return Array(userBankProfiles)
    }

    static func getKeeperForName(_ name: String, context: NSManagedObjectContext) throws -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.name.rawValue) = %@", name)
        let keepers = try context.fetch(fetchRequest)
        if keepers.isEmpty {
            return nil
        } else {
            return keepers[0]
        }
    }

    static func getFirstNonCashKeeper(context: NSManagedObjectContext) throws -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) != %i",
                                             Keeper.TypeEnum.cash.rawValue)
        let keepers = try context.fetch(fetchRequest)
        return keepers.first
    }

    static func getCashKeeper(context: NSManagedObjectContext) throws -> Keeper? {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) == %i",
                                             Keeper.TypeEnum.cash.rawValue)
        let keepers = try context.fetch(fetchRequest)
        if keepers.isEmpty {
            return nil
        } else {
            return keepers.first
        }
    }
}
