//
//  TransactionItem extension.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation

extension TransactionItem {
    enum Error: AppError, Equatable {
        case invalidAmountInDebitTransactioItem(path: String)
        case invalidAmountInCreditTransactioItem(path: String)
    }
}

extension TransactionItem.Error {
    public var errorDescription: String? {
        switch self {
        case let .invalidAmountInDebitTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value to account/category \"%@\"",
                                                    comment: ""), name)
        case let .invalidAmountInCreditTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value from account/category \"%@\"",
                                                    comment: ""), name)
        }
    }
}
