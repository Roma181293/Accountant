//
//  AccountWithBalanceError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum AccountWithBalanceError: AppError {
    case emptyAccountName
    case emptyBalance
    case emptyCreditLimit
    case emptyExchangeRate
    case canNotFindBeboreAccountingPeriodAccount
    case notSupported
}

extension AccountWithBalanceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyAccountName:
            return NSLocalizedString("Please enter the account name", comment: "")
        case .emptyBalance:
            return NSLocalizedString("Please enter balance", comment: "")
        case .emptyCreditLimit:
            return NSLocalizedString("Please enter credit limit", comment: "")
        case .emptyExchangeRate:
            return NSLocalizedString("Please enter exchange rate", comment: "")
        case .canNotFindBeboreAccountingPeriodAccount:
            return NSLocalizedString("Can not find \"Bebore accounting period\" account. Please contact support", comment: "")
        case .notSupported:
            return NSLocalizedString("Not supported", comment: "")
        }
    }
}
