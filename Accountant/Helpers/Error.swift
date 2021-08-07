//
//  Error.swift
//  Accountant
//
//  Created by Roman Topchii on 06.08.2021.
//

import Foundation

enum AccountError : Error {
    case attributeTypeShouldBeInitializeForRootAccount
    case accountHasAnAttribureTypeDifferentFromParent
    case accontAlreadyExists(name: String)
    case cantRemoveAccountThatUsedInTransactionItem(String)
    case creditAccountAlreadyExist(String)  //for cases when creates linked account
    case reservedAccountName
    case accountDoesNotExist(String)
}

extension AccountError: LocalizedError {
    public var errorDescription: String? {
            switch self {
            case .attributeTypeShouldBeInitializeForRootAccount:
                return NSLocalizedString("Attribute type should be initialize for root account", comment: "")
                
            case .accountHasAnAttribureTypeDifferentFromParent:
                return NSLocalizedString("Account has an attribure type different from parent", comment: "")
                
            case let .accontAlreadyExists(name):
               return String(format: NSLocalizedString("Account with name '%@' already exist. Please use another name", comment: ""),name)
                
            case let .cantRemoveAccountThatUsedInTransactionItem(list):
                return NSLocalizedString("You can not remove this account, it should be free from transactions", comment: "")
                
            case let .creditAccountAlreadyExist(name):
                return String(format: NSLocalizedString("With card money account we also create associated credit account and this account %@ is already exist. Please use another account name",comment: ""), AccountsNameLocalisationManager.getLocalizedAccountName(.credits)+":"+name)
                
            case .reservedAccountName:
                return NSLocalizedString("This is app-reserved account name. Please use another name",comment: "")
                
            case let .accountDoesNotExist(name):
                return String(format: NSLocalizedString("'%@' account does not exist. Please contact to support", comment: ""), name)
            }
        }
    
    
//        public var failureReason: String? {
//
//        }
//        public var recoverySuggestion: String? {
//        
//        }
}

