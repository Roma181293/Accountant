//
//  TransactionItemError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum TransactionItemError: AppError, Equatable {
    case invalidAmountInDebitTransactioItem(path: String)
    case invalidAmountInCreditTransactioItem(path: String)
    case attributeTypeDidNotSpecified
}

extension TransactionItemError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidAmountInDebitTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value to account/category \"%@\"", comment: ""), name)
        case let .invalidAmountInCreditTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value from account/category \"%@\"", comment: ""), name)
        case .attributeTypeDidNotSpecified:
            return NSLocalizedString("There are one or more thansaction items with incorrect types value. Possible values: \"From\", \"Credit\", \"To\", \"Debit\"", comment: "")
        }
    }
}
