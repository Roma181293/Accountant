//
//  BankAccount extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

extension BankAccount {
    
    func findNotValidAccountCandidateForLinking() -> [Account] {
        guard let account = self.account, let siblings = self.account?.parent?.directChildrenList else {return []}
        return siblings.filter({
            $0.type != account.type || $0.currency != account.currency || $0 == account || $0.bankAccount != nil
        })
    }

    func delete(consentText: String) throws {
        if consentText == "MyBudget: Finance keeper" {
            managedObjectContext?.delete(self)
        } else {
            throw UserBankProfile.Error.invalidConsentText(consentText)
        }
    }

    enum Error: AppError {
        case alreadyExist(name: String?)
        case cantChangeLinkedAccountCozSubType
        case cantChangeLinkedAccountCozCurrency
        case invalidConsentText(_ text: String)
    }
}

extension BankAccount.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .alreadyExist(name): return NSLocalizedString("This account \(name ?? "") already added",
                                                               comment: "")
        case .cantChangeLinkedAccountCozSubType:
            return NSLocalizedString("Linked account can't be changed, because new account has different Type",
                                     comment: "")
        case .cantChangeLinkedAccountCozCurrency:
            return NSLocalizedString("Linked account can't be changed, because new account has different Currency",
                                     comment: "")
        case let .invalidConsentText(text):
            return String(format: NSLocalizedString("Consent text %@ is not equal to \"MyBudget: Finance keeper\"",
                                                    comment: ""), text)
        }
    }
}
