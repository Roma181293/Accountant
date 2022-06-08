//
//  TransactionViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//

import Foundation

struct TransactionViewModel {
    let id: UUID
    let date: Date
    let status: Transaction.Status
    let comment: String?
    let createDate: Date
    let modifyDate: Date
    let itemsList: [TransactionItemViewModel]
    let debitRootName: String?
    let creditRootName: String?

    init(transaction: Transaction) {
        self.id = transaction.id
        self.date = transaction.date
        self.status = transaction.status
        self.comment = transaction.comment
        self.createDate = transaction.createDate ?? Date()
        self.modifyDate = transaction.modifyDate ?? Date()

        var items = [TransactionItemViewModel]()
        transaction.itemsList.forEach({
            items.append(TransactionItemViewModel(transactionItem: $0))
        })
        self.itemsList = items

        debitRootName = transaction.itemsList.filter({$0.type == .debit}).first?.account?.rootAccount.name
        creditRootName = transaction.itemsList.filter({$0.type == .credit}).first?.account?.rootAccount.name
    }
}
