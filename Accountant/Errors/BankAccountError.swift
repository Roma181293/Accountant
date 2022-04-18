//
//  BankAccountError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum BankAccountError: AppError {
    case alreadyExist(name: String?)
    case cantChangeLinkedAccountCozSubType
    case cantChangeLinkedAccountCozCurrency
    case invalidConsentText(_ text: String)
}

extension BankAccountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .alreadyExist(name): return NSLocalizedString("This account \(name ?? "") already added", comment: "")
        case .cantChangeLinkedAccountCozSubType: return NSLocalizedString("Linked account can't be changed, because new account has different Type", comment: "")
        case .cantChangeLinkedAccountCozCurrency: return NSLocalizedString("Linked account can't be changed, because new account has different Currency", comment: "")
        case let .invalidConsentText(text): return String(format: NSLocalizedString("Consent text %@ is not equal to \"MyBudget: Finance keeper\"", comment: ""), text)
        }
    }
}
