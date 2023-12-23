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
            let rowRecord = TransactionRecordFromReport(trnsactionId: row[0],
                                                        transactionDate: formatter.date(from: row[1]),
                                                        transactionStatus: row[2],
                                                        transactionItemType: row[3],
                                                        account: row[4],
                                                        amount: Double(row[5]) ?? -1,
                                                        amountInAccountingCurrency: Double(row[6]) ?? -1,
                                                        comment: row[7])

            guard ["APPLIED", "ARCHIVED"].contains(where: {$0 == rowRecord.transactionStatus.uppercased()}) else {break}

            func getPreTransactionWithId(_ id: String) -> PreTransaction? {
                return preTransactionList.filter({$0.id == id}).first
            }

            var preTransaction: PreTransaction!
            if let pretransaction = getPreTransactionWithId(rowRecord.trnsactionId) {
                preTransaction = pretransaction
                if let transactionDate = rowRecord.transactionDate {
                    preTransaction.transaction.date = transactionDate
                }
            } else {
                preTransaction = PreTransaction()
                preTransaction.transaction = Transaction(context: context)
                preTransaction.id = rowRecord.trnsactionId
                preTransaction.transaction.date = rowRecord.transactionDate ?? Date()
                preTransaction.transaction.comment = rowRecord.comment != "" ? rowRecord.comment : nil

                preTransaction.transaction.createDate = Date()
                preTransaction.transaction.modifyDate = Date()
                preTransaction.transaction.createdByUser = true
                preTransaction.transaction.modifiedByUser = true
                preTransaction.transaction.status = .preDraft
                preTransaction.transaction.id = UUID()
                preTransactionList.append(preTransaction)
            }

            func findAccountWithPath(_ path: String) -> Account? {
                    return accounts.filter({$0.path.uppercased() == path.uppercased()}).first
            }

            let transactionItem = TransactionItem(context: context)

            if ["CREDIT", "FROM"].contains(where: {$0 == rowRecord.transactionItemType.uppercased()}) {
                transactionItem.type = .credit
            } else if ["DEBIT", "TO"].contains(where: {$0 == rowRecord.transactionItemType.uppercased()}) {
                transactionItem.type = .debit
            } else {
                throw WorkerError.attributeTypeDidNotSpecified
            }

            transactionItem.account = findAccountWithPath(rowRecord.account)
            transactionItem.amount = rowRecord.amount
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

struct TransactionRecordFromReport {
    let trnsactionId: String
    let transactionDate: Date?
    let transactionStatus: String
    let transactionItemType: String
    let account: String
    let amount: Double
    let amountInAccountingCurrency: Double
    let comment: String
}
