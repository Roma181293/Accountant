//
//  Currency.swift
//  Accounting
//
//  Created by Roman Topchii on 31.12.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData

final class Currency: BaseEntity {

    @NSManaged public var code: String
    @NSManaged public var iso4217: Int16
    @NSManaged public var name: String?
    @NSManaged public var isAccounting: Bool
    @NSManaged public var accounts: Set<Account>!
    @NSManaged public var exchangeRates: Set<Rate>!

    convenience init(code: String, iso4217: Int16, name: String?, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.code = code // UAH
        self.iso4217 = iso4217 // 980
        self.name = name
        self.isAccounting = false
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }
}
