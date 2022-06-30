//
//  ArchivingHistory.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation
import CoreData

class ArchivingHistory: BaseEntity {

    @objc enum Status: Int16 {
        case failure = 0
        case success = 1
    }

    @NSManaged public var date: Date
    @NSManaged public var status: Status
    @NSManaged public var comment: String?

    convenience init(date: Date, status: Status, comment: String? = nil, createdByUser: Bool = true,
                     context: NSManagedObjectContext) {
        self.init(id: UUID(), createdByUser: createdByUser, createDate: Date(), context: context)
        self.date = date
        self.status = status
        self.comment = comment
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchivingHistory> {
        return NSFetchRequest<ArchivingHistory>(entityName: "ArchivingHistory")
    }

    class func getArchivedPeriod(context: NSManagedObjectContext) -> Date? {
        let request = ArchivingHistory.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.ArchivingHistory.status) = %@",
                                        argumentArray: [Status.success])
        request.sortDescriptors = [NSSortDescriptor(key: Schema.ArchivingHistory.modifyDate.rawValue, ascending: false)]
        return try? context.fetch(request).first?.date
    }

    class func setArchivingPeriod(date: Date, createdByUser: Bool = true, context: NSManagedObjectContext) throws {
        do {
            if date > Date() {
                throw Error.dateInFuture
            }

            try TransactionHelper.archiveTransactions(before: date, context: context)
            _ = ArchivingHistory(date: date, status: .success, context: context)

        } catch let error {
            _ = ArchivingHistory(date: date, status: .failure, comment: error.localizedDescription, context: context)
        }
        try? context.save()
    }

    enum Error: AppError {
        case dateInFuture
        case periodhasUnAppliedTransactions
    }
}

extension ArchivingHistory.Error {
    public var errorDescription: String? {
        switch self {
        case .dateInFuture:
            return NSLocalizedString("Trying to set archive date in the future", comment: "")
        case .periodhasUnAppliedTransactions:
            return NSLocalizedString("At least one transaction has unapplied status before archiving date", comment: "")
        }
    }
}
