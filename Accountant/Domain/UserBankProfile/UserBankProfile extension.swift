//
//  UserBankProfile extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation

extension UserBankProfile {

    var bankAccountsList: [BankAccount] {
        return Array(bankAccounts)
    }

    func changeActiveStatus() {
        if self.active {
            self.active = false
            self.bankAccountsList.forEach({
                $0.active = false
            })
        } else {
            self.active = true
        }
    }

    func delete(consentText: String) throws {
        if consentText == "MyBudget: Finance keeper" {
            try bankAccountsList.forEach({
                try $0.delete(consentText: consentText)
            })
            managedObjectContext?.delete(self)
        } else {
            throw UserBankProfile.Error.invalidConsentText(consentText)
        }
    }

    enum Error: AppError {
        case alreadyExist
        case invalidConsentText(_ text: String)
    }
}

extension UserBankProfile.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .alreadyExist:
            return NSLocalizedString("This user bank profile already exists", comment: "")
        case let .invalidConsentText(text):
            return String(format: NSLocalizedString("Consent text %@ is not equal to \"MyBudget: Finance keeper\"",
                                                    comment: ""),
                          text)
        }
    }
}
