//
//  MITransactionEditorInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation

class MITransactionEditorInteractor: MITransactionEditorInteractorInput {

    var isNewTransaction: Bool {
        return worker.isNewTransaction
    }

    var transactionDate: Date {
        get {
            return worker.transactionDate
        }
    }

    var accountingCurrencyCode: String {
        return worker.accountingCurrencyCode
    }

    var transactionStatus: Transaction.Status {
        return worker.transactionStatus
    }

    var hasChanges: Bool {
        return worker.hasChanges
    }

    let worker: MITransactionEditor
    weak var output: MITransactionEditorInteractorOutput?

    init(worker: MITransactionEditor) {
        self.worker = worker
        if worker.isNewTransaction {
            self.worker.addEmptyTransactionItem()
        }
    }

    func fetchData() {
        worker.fetchData()
    }

    func setDate(_ date: Date) throws {
        try worker.setDate(date)
    }

    func addEmptyTransactionItem(type: TransactionItem.TypeEnum) {
        worker.addEmptyTransactionItem(type: type)
    }

    func deleteTransactionItem(id: UUID) {
        worker.deleteTransactionItem(id: id)
    }

    func setAccount(_ account: Account, forTransactionItem id: UUID) {
        worker.setAccount(account, forTransactionItem: id)
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double, amountInAccountingCurrency: Double) {
        worker.setAmount(forTrasactionItem: id, amount: amount, amountInAccountingCurrency: amountInAccountingCurrency)
    }

    func setComment(_ comment: String?) {
        worker.setComment(comment)
    }

    func usedAccountList() -> [Account] {
        return worker.usedAccountList()
    }

    func rootAccountFor(transactionItemId: UUID) -> Account? {
        return worker.rootAccountFor(transactionItemId: transactionItemId)
    }

    func save() throws {
        try worker.save()
    }

    func cleanUnusedData() {
        worker.cleanUnusedData()
    }
}
