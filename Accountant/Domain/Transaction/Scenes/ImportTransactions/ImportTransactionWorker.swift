//
//  ImportTransactionWorker.swift
//  Accountant
//
//  Created by Roman Topchii on 01.07.2022.
//

import Foundation
import CoreData

class ImportTransactionWorker {
    class func importTransactionList(from data: String, context: NSManagedObjectContext) throws -> [PreTransaction] {
        var inputMatrix: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            inputMatrix.append(columns)
        }
        inputMatrix.remove(at: 0)

        // load accounts from the DB
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let accountFetchRequest = Account.fetchRequest()
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: false)]
        let accounts = try context.fetch(accountFetchRequest)

        var preTransactionList: [PreTransaction] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"

        for row in inputMatrix {
            guard row.count > 1 else {break}

            func getPreTransactionWithId(_ id: String) -> PreTransaction? {
                let candidate = preTransactionList.filter({if $0.id == id {return true} else {return false}})
                if candidate.count == 1 {
                    return candidate[0]
                }
                return nil
            }

            var preTransaction: PreTransaction!
            if let pretransaction = getPreTransactionWithId(row[0]) {
                preTransaction = pretransaction
                if let date = formatter.date(from: row[1]) {
                    preTransaction.transaction.date = date
                }
            } else {
                preTransaction = PreTransaction()
                preTransaction.transaction = Transaction(context: context)
                preTransaction.id = row[0]
                preTransaction.transaction.date = formatter.date(from: row[1]) ?? Date()

                if row[5] != "" {
                    preTransaction.transaction.comment = row[5]
                }

                preTransaction.transaction.createDate = Date()
                preTransaction.transaction.modifyDate = Date()
                preTransaction.transaction.createdByUser = true
                preTransaction.transaction.modifiedByUser = true
                preTransaction.transaction.status = .preDraft
                preTransaction.transaction.id = UUID()
                preTransactionList.append(preTransaction)
            }

            func findAccountWithPath(_ path: String) -> Account? {
                for account in accounts where account.path == path {
                    return account
                }
                return nil
            }

            let transactionItem = TransactionItem(context: context)
            if row[2].uppercased() == "CREDIT" || row[2].uppercased() == "FROM" {
                transactionItem.type = .credit
            } else if row[2].description.uppercased() == "DEBIT" || row[2].uppercased() == "TO" {
                transactionItem.type = .debit
            }
            else {
                throw WorkerError.attributeTypeDidNotSpecified
            }
            transactionItem.account = findAccountWithPath(row[3])
            if let amount = Double(row[4]) {
                transactionItem.amount = amount
            } else {
                transactionItem.amount = -1
            }

            transactionItem.transaction = preTransaction.transaction
            transactionItem.id = UUID()
            transactionItem.createDate = Date()
            transactionItem.modifyDate = Date()
            transactionItem.createdByUser = true
            transactionItem.modifiedByUser = true
        }
        return preTransactionList
    }

    enum WorkerError: AppError, Equatable {
        case attributeTypeDidNotSpecified
    }
}

extension ImportTransactionWorker.WorkerError {
    public var errorDescription: String? {
        switch self {
        case .attributeTypeDidNotSpecified:
            return NSLocalizedString("There are one or more thansaction items with incorrect types value. " +
                                     "Possible values: \"From\", \"Credit\", \"To\", \"Debit\"", comment: "")
        }
    }
}

