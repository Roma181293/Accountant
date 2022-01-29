//
//  UserBankProfileError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum UserBankProfileError: AppError {
    case alreadyExist
    case invalidConsentText(_ text: String)
}

extension UserBankProfileError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .alreadyExist: return NSLocalizedString("This user bank profile already exists",comment: "")
        case let .invalidConsentText(text): return String(format: NSLocalizedString("Consent text %@ is not equal to \"MyBudget: Finance keeper\"", comment: ""), text)
        }
    }
}
