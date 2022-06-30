//
//  MITransactionEditorInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation

class MITransactionEditorInteractor: MITransactionEditorInteractorInput {

    weak var output: MITransactionEditorInteractorOutput?

    private(set) var isNewTransaction: Bool = true
    private(set) var transaction: Transaction

    var transactionDate: Date {
        get {
            return transaction.date
        }
        set {
            transaction.date = newValue
        }
    }

    var transactionStatus: Transaction.Status {
        return transaction.status
    }

    var hasChanges: Bool {
        return viewContext.hasChanges
    }

    private let persistentContainer = CoreDataStack.shared.persistentContainer
    private lazy var viewContext = {
        return persistentContainer.viewContext
    }()

    required init(transaction: Transaction?) {
        if let transaction = transaction {
            self.transaction = transaction
            isNewTransaction = false
        } else {
            self.transaction = Transaction(date: Date(), context: persistentContainer.viewContext)
            addEmptyTransactionItem(type: .credit)
        }
    }

    func addEmptyTransactionItem(type: TransactionItem.TypeEnum) {
        if transaction.itemsList.count == 1 {
           _ = TransactionItem(transaction: transaction, type: type, amount: transaction.itemsList.first!.amount,
                               context: viewContext)
        } else {
           _ = TransactionItem(transaction: transaction, type: type, amount: 0, context: viewContext)
        }
        output?.fetched(transactionItems: transaction.itemsList)
    }

    func deleteTransactionItem(id: UUID) {
        transaction.itemsList.filter({$0.id == id}).forEach({
            $0.transaction = nil
            viewContext.delete($0)
        })
        output?.fetched(transactionItems: transaction.itemsList)
    }

    func fetchData() {
        output?.fetched(transactionItems: self.transaction.itemsList)
        output?.fetched(date: transaction.date)
        output?.fetched(comment: transaction.comment)
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

    func setAmount(forTrasactionItem id: UUID, amount: Double) {
        let item = getTransactionItemWithId(id)
        item?.amount = amount
        item?.modifyDate = Date()
        item?.modifiedByUser = true
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

    func validateTransaction() throws {
        return try TransactionHelper.validateTransactionDataBeforeSave(transaction)
    }

    func save() {
        guard transaction.status != .preDraft else {return}
        if transactionDate < Date() {
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
            viewContext.save(with: .addMultiItemTransaction)
        } else {
            viewContext.save(with: .editMultiItemTransaction)
        }
    }

    func cleanUnusedData() {
        if viewContext.hasChanges && transaction.status != .preDraft {
            viewContext.rollback()
        }
    }

    private func getTransactionItemWithId(_ id: UUID) -> TransactionItem? {
        for item in transaction.itemsList where item.id == id {
            return item
        }
        return nil
    }
}
