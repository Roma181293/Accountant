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
    let amountInAccountingCurrency: Double
    let type: TransactionItem.TypeEnum
    let createDate: Date
    let currency: String
    let isAccountingCurrency: Bool

    init(transactionItem: TransactionItem) {
        self.id = transactionItem.id
        self.path = transactionItem.account?.path ?? NSLocalizedString("Account/Category",
                                                                       tableName: Constants.Localizable.mITransactionEditor,
                                                                       comment: "")
        self.amount = transactionItem.amount
        self.amountInAccountingCurrency = transactionItem.amountInAccountingCurrency
        self.type = transactionItem.type
        self.createDate = transactionItem.createDate ?? Date()
        self.currency = transactionItem.account?.currency?.code ?? ""
        self.isAccountingCurrency = transactionItem.account?.currency?.isAccounting ?? true
    }
}
