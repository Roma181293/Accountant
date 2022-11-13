//
//  TransactionItemViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//

import Foundation

struct TransactionItemSimpleViewModel {
    let id: UUID
    let path: String
    let amount: Double
    let type: TransactionItem.TypeEnum
    let createDate: Date
    let currency: String

    init(transactionItem: TransactionItem) {
        self.id = transactionItem.id
        let path = transactionItem.account?.path ?? NSLocalizedString("Account/Category",
                                                         tableName: Constants.Localizable.mITransactionEditor,
                                                         comment: "")
        self.path = path
        self.amount = transactionItem.amount
        self.type = transactionItem.type
        self.createDate = transactionItem.createDate ?? Date()
        self.currency = transactionItem.account?.currency?.code ?? ""
    }
}
