//
//  TransactionError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum TransactionError : AppError, Equatable {
    case differentAmountForSingleCurrecyTransaction
    case noDebitTransactionItem
    case noCreditTransactionItem
    case debitTransactionItemWOAccount
    case creditTransactionItemWOAccount
    case multicurrencyAccount(name: String)
}

extension TransactionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .differentAmountForSingleCurrecyTransaction:
            return NSLocalizedString("You have a transaction in the same currency, but amounts in From:Account and To:Account are not matching",comment: "")
        case .noDebitTransactionItem:
            return NSLocalizedString("Please add To:Account",comment: "")
        case .noCreditTransactionItem:
            return NSLocalizedString("Please add From:Account",comment: "")
        case .debitTransactionItemWOAccount:
            return NSLocalizedString("Please select To:Account",comment: "")
        case .creditTransactionItemWOAccount:
            return NSLocalizedString("Please select From:Account",comment: "")
        case let .multicurrencyAccount(name):
            return String(format: NSLocalizedString("Please create a subaccount for \"%@\" and select it", comment: ""), name)
        }
    }
}
