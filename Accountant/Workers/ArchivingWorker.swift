//
//  ArchivingWorker.swift
//  Accountant
//
//  Created by Roman Topchii on 06.07.2022.
//

import Foundation
import CoreData
import CryptoKit

protocol ArchivingWorkerDelegate: AnyObject {
    func didFetch(_ list: [ArchivingHistoryViewModel])
}

class ArchivingWorker: NSObject {

    weak var delegate: ArchivingWorkerDelegate?

    private let persistentContainer: PersistentContainer
    private let transactionStatusWorker: TransactionStatusWorker

    init(transactionStatusWorker: TransactionStatusWorker, persistentContainer: PersistentContainer) {
        self.transactionStatusWorker = transactionStatusWorker
        self.persistentContainer = persistentContainer
    }

    private(set) lazy var fetchedResultsController: NSFetchedResultsController<ArchivingHistory> = {
        let fetchRequest = ArchivingHistory.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.ArchivingHistory.createDate.rawValue, ascending: false)]
        fetchRequest.fetchBatchSize = 20

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    class func getCurrentArchivedPeriod(context: NSManagedObjectContext) -> Date? {
        let request = ArchivingHistory.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.ArchivingHistory.status) = %@",
                                        argumentArray: [ArchivingHistory.Status.success.rawValue])
        request.sortDescriptors = [NSSortDescriptor(key: Schema.ArchivingHistory.createDate.rawValue, ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first?.date
    }

    func setArchivingPeriod(date: Date, createdByUser: Bool = true) {
        do {
            let context = persistentContainer.newBackgroundContext()

            do {
                if date > Date() {
                    throw WorkerError.dateInFuture
                }

                if let currentArchivedPeriod = ArchivingWorker.getCurrentArchivedPeriod(context: context), currentArchivedPeriod > date {
                    transactionStatusWorker.unArchiveTransactions(after: date)
                } else {
                    try transactionStatusWorker.archiveTransactions(before: date)
                }
                _ = ArchivingHistory(date: date, status: .success, context: context)

            } catch let error {
                print(error.localizedDescription)
                _ = ArchivingHistory(date: date, status: .failure, comment: error.localizedDescription, context: context)
            }

            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchData() {
        try? fetchedResultsController.performFetch()
        if let list = fetchedResultsController.fetchedObjects?.compactMap({item in ArchivingHistoryViewModel(archivingHistory: item)}) {
            delegate?.didFetch(list)
        } else {
            delegate?.didFetch([])
        }
    }

    enum WorkerError: AppError {
        case dateInFuture
    }
}

extension ArchivingWorker.WorkerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dateInFuture:
            return NSLocalizedString("Trying to set archive date in the future", tableName: "ArchivinHistoryLocalizable", comment: "")
        }
    }
}

extension ArchivingWorker: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let list = fetchedResultsController.fetchedObjects?.compactMap({item in ArchivingHistoryViewModel(archivingHistory: item)}) {
            delegate?.didFetch(list)
        } else {
            delegate?.didFetch([])
        }
    }
}
