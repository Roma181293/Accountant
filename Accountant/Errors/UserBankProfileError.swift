//
//  UserBankProfileError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum UserBankProfileError: AppError {
    case alreadyExist
   
}

extension UserBankProfileError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .alreadyExist:
            return NSLocalizedString("This user bank profile already exists",comment: "")
        }
    }
}
