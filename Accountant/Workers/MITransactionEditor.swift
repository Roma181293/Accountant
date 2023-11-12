//
//  MITransactionEditor.swift
//  Accountant
//
//  Created by Roman Topchii on 01.07.2022.
//

import Foundation
import CoreData

protocol MITransactionEditorDelegate: AnyObject {
    func fetched(transactionItems: [TransactionItem])
    func fetched(date: Date)
    func fetched(comment: String?)
    func disableEdit()
}

protocol MITransactionEditorInput: AnyObject {
    var isNewTransaction: Bool { get }
    var accountingCurrencyCode: String { get }
    var transactionDate: Date { get }
    func setDate(_ date: Date) throws
    var transactionStatus: Transaction.Status { get }
    var hasChanges: Bool { get }
    func fetchData()
    func addEmptyTransactionItem(type: TransactionItem.TypeEnum)
    func deleteTransactionItem(id: UUID)
    func setAccount(_ account: Account, forTransactionItem id: UUID)
    func setAmount(forTrasactionItem id: UUID, amount: Double, amountInAccountingCurrency: Double)
    func setComment(_ comment: String?)
    func usedAccountList() -> [Account]
    func rootAccountFor(transactionItemId: UUID) -> Account?
    func save() throws
    func cleanUnusedData()
}

class MITransactionEditor: MITransactionEditorInput {

    weak var delegate: MITransactionEditorDelegate?

    private(set) var isNewTransaction: Bool = true
    var accountingCurrencyCode: String {
        return CurrencyHelper.getAccountingCurrency(context: context)?.code ?? ""
    }
    private(set) var transaction: Transaction
    let archivedPeriodDate: Date?
    var transactionDate: Date {
        return transaction.date
    }

    var transactionStatus: Transaction.Status {
        return transaction.status
    }

    var hasChanges: Bool {
        return context.hasChanges
    }

    private let context: NSManagedObjectContext

    init(transactionId: UUID?, archivedPeriodDate: Date?, context: NSManagedObjectContext) {
        self.context = context
        self.archivedPeriodDate = archivedPeriodDate
        if let transactionId = transactionId,
            let transaction = TransactionHelper.getTransactionFor(id: transactionId, context: context) {
            self.transaction = transaction
            isNewTransaction = false
        } else {
            self.transaction = Transaction(date: Date(), context: context)
        }
    }

    func addEmptyTransactionItem(type: TransactionItem.TypeEnum = .credit) {
        if transaction.itemsList.count == 1 {
            _ = TransactionItem(transaction: transaction, type: type, amount: transaction.itemsList.first!.amount,
                                context: context)
        } else {
            _ = TransactionItem(transaction: transaction, type: type, amount: 0, context: context)
        }
        delegate?.fetched(transactionItems: transaction.itemsList)
    }

    func deleteTransactionItem(id: UUID) {
        transaction.itemsList.filter({$0.id == id}).forEach({
            $0.transaction = nil
            context.delete($0)
        })
        delegate?.fetched(transactionItems: transaction.itemsList)
    }

    func fetchData() {
        delegate?.fetched(transactionItems: self.transaction.itemsList)
        delegate?.fetched(date: transaction.date)
        delegate?.fetched(comment: transaction.comment)
        if transaction.status == .archived {
            delegate?.disableEdit()
        }
    }

    func setDate(_ date: Date) throws {
        if let archivedPeriodDate = archivedPeriodDate, date < archivedPeriodDate {
            delegate?.fetched(date: transaction.date)
            throw TransactionHelper.HelperError.cannotSetTransactionDateInClosedPeriod
        } else {
            transaction.date = date
        }
    }

    func setAccount(_ account: Account, forTransactionItem id: UUID) {
        let item = getTransactionItemWithId(id)
        item?.account = account
        item?.modifyDate = Date()
        item?.modifiedByUser = true
        /*
         no need to call
         output?.fetched(transactionItems: self.transaction.itemsList)
         coz view updates in viewWillAppear() method
         */
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double, amountInAccountingCurrency: Double) {
        let item = getTransactionItemWithId(id)
        item?.amount = amount
        item?.amountInAccountingCurrency = amountInAccountingCurrency
        item?.modifyDate = Date()
        item?.modifiedByUser = true
        delegate?.fetched(transactionItems: self.transaction.itemsList)
    }

    func setComment(_ comment: String?) {
        if let comment = comment, !comment.isEmpty {
            transaction.comment = comment
        } else {
            transaction.comment = nil
        }
    }

    func usedAccountList() -> [Account] {
        var result: [Account] = []
        for tranItem in transaction.itemsList {
            if let account = tranItem.account {
                result.append(account)
            }
        }
        return result
    }

    func rootAccountFor(transactionItemId: UUID) -> Account? {
        if let type = transaction.itemsList.filter({$0.id == transactionItemId}).first?.type {
            if transaction.itemsList.filter({$0.type == type}).count <= 1 {
                return nil
            }
            return transaction.itemsList.filter({$0.type == type && $0.account != nil}).first?.account?.rootAccount
        }
        return nil
    }

    func save() throws {
        try TransactionHelper.validateTransactionDataBeforeSave(transaction)
        transaction.calculateType()
        guard transaction.status != .preDraft else {return}
        if transaction.date < Date() {
            transaction.status = .applied
        } else {
            transaction.status = .approved
        }
        if isNewTransaction {
            let date = Date()
            transaction.createDate = date
            transaction.modifyDate = date
            transaction.itemsList.forEach({
                $0.createDate = date
                $0.modifyDate = date
            })
            context.save(with: .addMultiItemTransaction)
        } else {
            context.save(with: .editMultiItemTransaction)
        }
    }

    func cleanUnusedData() {
        if context.hasChanges && transaction.status != .preDraft {
            context.rollback()
        }
    }

    private func getTransactionItemWithId(_ id: UUID) -> TransactionItem? {
        for item in transaction.itemsList where item.id == id {
            return item
        }
        return nil
    }
}
