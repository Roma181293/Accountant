//
//  ArchivingHistoryHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 03.07.2022.
//

import Foundation
import CoreData

class ArchivingHistoryHelper {
    
    class func getArchivedPeriod(context: NSManagedObjectContext) -> Date? {
        let request = ArchivingHistory.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.ArchivingHistory.status) = %@",
                                        argumentArray: [ArchivingHistory.Status.success])
        request.sortDescriptors = [NSSortDescriptor(key: Schema.ArchivingHistory.createDate.rawValue, ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first?.date
    }

    class func setArchivingPeriod(date: Date, createdByUser: Bool = true, context: NSManagedObjectContext) throws {
        do {
            if date > Date() {
                throw HelperError.dateInFuture
            }

            try TransactionHelper.archiveTransactions(before: date, context: context)
            _ = ArchivingHistory(date: date, status: .success, context: context)

        } catch let error {
            _ = ArchivingHistory(date: date, status: .failure, comment: error.localizedDescription, context: context)
        }
        try? context.save()
    }

    enum HelperError: AppError {
        case dateInFuture
    }
}

extension ArchivingHistoryHelper.HelperError {
    public var errorDescription: String? {
        switch self {
        case .dateInFuture:
            return NSLocalizedString("Trying to set archive date in the future", comment: "")
        }
    }
}
