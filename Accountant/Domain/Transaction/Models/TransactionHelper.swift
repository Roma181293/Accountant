//
//  TransactionHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation
import CoreData

class TransactionHelper {

    class func getTransactionFor(id: UUID, context: NSManagedObjectContext) -> Transaction? {
        let request = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.Transaction.id) = '\(id)'")
        request.sortDescriptors = [NSSortDescriptor(key: "\(Schema.Transaction.createDate)", ascending: true)]
        return try? context.fetch(request).first
    }

    private class func getDataAboutTransactionItems(transaction: Transaction, type: TransactionItem.TypeEnum,
                                                    amount: inout Double, currency: inout Currency?,
                                                    itemsCount: inout Int) throws {
        for item in transaction.itemsList.filter({$0.type == type}) {
            itemsCount += 1
            amount += item.amount
            if let account = item.account {
                if let cur = account.currency {
                    if currency != cur {
                        currency = nil // multicurrency transaction
                    }
                } else {
                    throw HelperError.multicurrencyAccount(name: account.path)
                }

                if item.amount <= 0 {
                    switch type {
                    case .debit:
                        throw HelperError.invalidAmountInDebitTransactioItem(path: account.path)
                    case .credit:
                        throw HelperError.invalidAmountInCreditTransactioItem(path: account.path)
                    }
                }
            } else {
                switch type {
                case .debit:
                    throw TransactionHelper.HelperError.debitTransactionItemWOAccount
                case .credit:
                    throw TransactionHelper.HelperError.creditTransactionItemWOAccount
                }
            }
        }
    }

    class func validateTransactionDataBeforeSave(_ transaction: Transaction) throws {

        var debitAmount: Double = 0
        var creditAmount: Double = 0
        var debitItemsCount: Int = 0
        var creditItemsCount: Int = 0

        //  Prepare data to check ability for save transaction
        var creditCurrency: Currency? = transaction.itemsList.filter({$0.type == .credit}).first?.account?.currency
        var debitCurrency: Currency? = transaction.itemsList.filter({$0.type == .debit}).first?.account?.currency

        try getDataAboutTransactionItems(transaction: transaction, type: .credit, amount: &creditAmount,
                                         currency: &creditCurrency, itemsCount: &creditItemsCount)
        try getDataAboutTransactionItems(transaction: transaction, type: .debit, amount: &debitAmount,
                                         currency: &debitCurrency, itemsCount: &debitItemsCount)
        // Check ability to save transaction

        if debitItemsCount == 0 {
            throw TransactionHelper.HelperError.noDebitTransactionItem
        }
        if creditItemsCount == 0 {
            throw TransactionHelper.HelperError.noCreditTransactionItem
        }
        if debitCurrency == creditCurrency {
            if round(debitAmount*100) != round(creditAmount*100) {
                throw TransactionHelper.HelperError.differentAmountInSingleCurrecyTran
            }
        }
    }

    class func createAndGetSimpleTran(date: Date, debit: Account, credit: Account, debitAmount: Double = 0,
                                      creditAmount: Double = 0, comment: String? = nil,
                                      createdByUser: Bool = true, context: NSManagedObjectContext) -> Transaction {
        let createDate = Date()
        let transaction = Transaction(date: date, comment: comment, createdByUser: createdByUser,
                                      createDate: createDate, context: context)
        if transaction.date < Date() {
            transaction.status = .applied
        } else {
            transaction.status = .approved
        }
        _ = TransactionItem(transaction: transaction, type: .credit, account: credit, amount: creditAmount,
                            createdByUser: createdByUser, createDate: createDate, context: context)
        _ = TransactionItem(transaction: transaction, type: .debit, account: debit, amount: debitAmount,
                            createdByUser: createdByUser, createDate: createDate, context: context)
        transaction.calculateType()
        return transaction
    }

    class func createSimpleTran(date: Date, debit: Account, credit: Account, debitAmount: Double = 0,
                                creditAmount: Double = 0, comment: String? = nil,
                                createdByUser: Bool = true, context: NSManagedObjectContext) {
        _ = createAndGetSimpleTran(date: date, debit: debit, credit: credit, debitAmount: debitAmount, creditAmount: creditAmount, comment: comment, createdByUser: createdByUser, context: context)
    }

    class func duplicateTransaction(_ original: Transaction, createdByUser: Bool = true, createDate: Date = Date(),
                                    context: NSManagedObjectContext) {

        let transaction = Transaction(date: original.date, comment: original.comment, createdByUser:
                                        createdByUser, createDate: createDate, context: context)
        transaction.status = original.status
        transaction.type = original.type
        for item in original.itemsList {
            _ = TransactionItem(transaction: transaction, type: item.type, account: item.account!,
                                amount: item.amount, context: context)
        }
    }

    class func addTransactionDraft(account: Account, statment: StatementProtocol, createdByUser: Bool = false,
                                   createDate: Date = Date(), context: NSManagedObjectContext) -> Transaction {
        let comment = statment.getComment()
        let transaction = Transaction(date: statment.getDate(), comment: comment, createdByUser: createdByUser,
                                      createDate: createDate, context: context)
        transaction.status = .draft

        if statment.getType() == .to {
            _ = TransactionItem(transaction: transaction,
                                type: .debit,
                                account: account,
                                amount: statment.getAmount(),
                                createdByUser: createdByUser,
                                createDate: createDate,
                                context: context)
            if let creditAccount = findAccountCandidate(comment: comment,
                                                        account: account,
                                                        transactionItemType: .credit) {
                _ = TransactionItem(transaction: transaction,
                                    type: .credit,
                                    account: creditAccount,
                                    amount: statment.getAmount(),
                                    createdByUser: createdByUser,
                                    createDate: createDate,
                                    context: context)
            }
        } else {
            _ = TransactionItem(transaction: transaction,
                                type: .credit,
                                account: account,
                                amount: statment.getAmount(),
                                createdByUser: createdByUser,
                                createDate: createDate,
                                context: context)
            if let debitAccount = findAccountCandidate(comment: comment,
                                                       account: account,
                                                       transactionItemType: .debit) {
                _ = TransactionItem(transaction: transaction,
                                    type: .debit,
                                    account: debitAccount,
                                    amount: statment.getAmount(),
                                    createdByUser: createdByUser,
                                    createDate: createDate,
                                    context: context)
            }
        }
        return transaction
    }

    private class func findAccountCandidate(comment: String, account: Account,
                                            transactionItemType: TransactionItem.TypeEnum) -> Account? {

        // 0. Find all transactionItems for account ciblings
        guard let parent = account.parent else {return nil}

        var accountTIs1: [TransactionItem] = []
        let ciblings = parent.directChildrenList
        ciblings.forEach({item in
            accountTIs1.append(contentsOf: item.transactionItemsList)
        })

        // 1. Find all transactionItems there transaction has equal comment and applied status
        let accountTIs = accountTIs1.filter({$0.transaction?.comment == comment && $0.transaction?.status == .applied})

        // 2. Find all thansactions for transactionItems from step 1
        var transactions: [Transaction] = []
        accountTIs.forEach({transactions.append($0.transaction!)})

        /* 3. Preperation. Find pairs (account, transactionDate) fot transactions from step 2 where account != account
         from the method signature. create account set
         */
        var zeroIterationCandidatesArray: [(account: Account, transactionDate: Date)] = []
        var accountSet: Set<Account> = []
        for transaction in transactions {
            for tranItem in transaction.itemsList where  tranItem.account != account
            && tranItem.type == transactionItemType && account.active == true && (account.directChildrenList).isEmpty {
                zeroIterationCandidatesArray.append((account: tranItem.account!, transactionDate: transaction.date))
                accountSet.insert(tranItem.account!)
            }
        }

        // 4. For all uniuqe accounts from accountset create [(account: Account, lastTranDate: Date, count: Int)]
        var firstIterationCandidatesArray: [(account: Account, lastTranDate: Date, count: Int)] = []
        accountSet.forEach({ acc in
            let count = zeroIterationCandidatesArray.filter({ $0.account == acc }).count
            let maxDate = zeroIterationCandidatesArray.filter({$0.account == acc}).max(by: {
                $0.transactionDate < $1.transactionDate})!.transactionDate
            firstIterationCandidatesArray.append((acc, maxDate, count))
        })

        // 5. Find all candidates with max count
        guard let firstMax = firstIterationCandidatesArray.sorted(by: {$0.lastTranDate >= $1.lastTranDate}).first
        else {return nil}
        let secondIterationCandidatesArray = firstIterationCandidatesArray.filter({firstMax.count == $0.count})
        if !secondIterationCandidatesArray.isEmpty {
            return secondIterationCandidatesArray.first?.account
        } else {
            // 6. Find all candidates with max lastTranDate from step 5
            guard let secondMax = secondIterationCandidatesArray.sorted(by: {$0.lastTranDate >= $1.lastTranDate}).first
            else {return nil}
            let thirdIterationCandidatesArray = secondIterationCandidatesArray.filter({secondMax.lastTranDate == $0.lastTranDate})
            if !thirdIterationCandidatesArray.isEmpty {
                return thirdIterationCandidatesArray.first?.account
            } else {
                return nil
            }
        }
    }

    class func exportTransactionsToString(context: NSManagedObjectContext) -> String {
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Transaction.status.rawValue) = " +
                                             "\(Transaction.Status.applied.rawValue) || " +
                                             "\(Schema.Transaction.status.rawValue) = " +
                                             "\(Transaction.Status.approved.rawValue)")
        do {
            let storedTransactions = try context.fetch(fetchRequest)
            var export: String = "Id,Date,Type,Account,Amount,Comment"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
            for transaction in storedTransactions {
                for item in transaction.itemsList {
                    export += "\n"
                    export +=  String(describing: transaction.id) + ","
                    export +=  String(describing: formatter.string(from: transaction.date)) + ","

                    var type: String = ""
                    if item.type == .credit {
                        type = "Credit"
                    } else if item.type == .debit {
                        type = "Debit"
                    }
                    export +=  type + ","
                    export +=  String(describing: item.account!.path) + ","
                    export +=  String(describing: item.amount) + ","
                    export +=  "\(transaction.comment ?? "")"
                }
            }
            return export
        } catch {
            return ""
        }
    }

    class func importMonobankStatments(_ statments: [MBStatement], for account: Account,
                                       context: NSManagedObjectContext) {
        for statment in statments {
            _ = addTransactionDraft(account: account, statment: statment, createdByUser: false, context: context)
        }
    }

    class func getDateForFirstTransaction(context: NSManagedObjectContext) -> Date? {
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
        fetchRequest.fetchBatchSize = 1
        return try? context.fetch(fetchRequest).first?.date
    }

    enum HelperError: AppError {
        case periodHasUnAppliedTransactions
        case differentAmountInSingleCurrecyTran
        case noDebitTransactionItem
        case noCreditTransactionItem
        case debitTransactionItemWOAccount
        case creditTransactionItemWOAccount
        case multicurrencyAccount(name: String)
        case invalidAmountInDebitTransactioItem(path: String)
        case invalidAmountInCreditTransactioItem(path: String)
    }
}

extension TransactionHelper.HelperError: LocalizedError {
    private var tableName: String {
        return Constants.Localizable.transaction
    }
    public var errorDescription: String? {
        switch self {
        case .periodHasUnAppliedTransactions:
            return NSLocalizedString("There is an unapplied transaction before this date", tableName: tableName, comment: "")
        case .differentAmountInSingleCurrecyTran:
            return NSLocalizedString("You have a transaction in the same currency, but amounts in From:Account and " +
                                     "To:Account are not matching", tableName: tableName, comment: "")
        case .noDebitTransactionItem:
            return NSLocalizedString("Please add To:Account", tableName: tableName, comment: "")
        case .noCreditTransactionItem:
            return NSLocalizedString("Please add From:Account", tableName: tableName, comment: "")
        case .debitTransactionItemWOAccount:
            return NSLocalizedString("Please select To:Account", tableName: tableName, comment: "")
        case .creditTransactionItemWOAccount:
            return NSLocalizedString("Please select From:Account", tableName: tableName, comment: "")
        case let .multicurrencyAccount(name):
            return String(format: NSLocalizedString("Please create a subaccount for \"%@\" and select it", tableName: tableName,
                                                    comment: ""),
                          name)
        case let .invalidAmountInDebitTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value to account/category \"%@\"", tableName: tableName,
                                                    comment: ""), name)
        case let .invalidAmountInCreditTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value from account/category \"%@\"", tableName: tableName,
                                                    comment: ""), name)
        }
    }
}
