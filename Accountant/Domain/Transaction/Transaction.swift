//
//  Transaction.swift
//  Accounting
//
//  Created by Roman Topchii on 03.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData

final class Transaction: BaseEntity {

    @objc enum Status: Int16 {
        case preDraft = 0
        case draft = 1
        case approved = 2
        case applied = 3
        case archived = 4
    }

    @objc enum TypeEnum: Int16 {
        case unknown = 0 // for incomplete transaction
        case income = 1 // from Income
        case expense = 2 // to Expense
        case transfer = 3 // Money<->Money, Money<->Debtors, Money<->Creditors, Debtors<->Creditors
        case initialBalance = 4 // seted manually. cannot be changed in future
        case other = 5
    }

    @NSManaged public var date: Date
    @NSManaged public var status: Status
    @NSManaged public var type: TypeEnum
    @NSManaged public var comment: String?
    @NSManaged public var items: Set<TransactionItem>!

    convenience init(date: Date, status: Status = .approved, comment: String? = nil, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.date = date
        self.status = status
        self.comment = comment
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
}
