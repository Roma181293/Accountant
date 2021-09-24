//
//  Error.swift
//  Accountant
//
//  Created by Roman Topchii on 06.08.2021.
//

import Foundation

protocol AppError: Error {}




enum AccountError : AppError {
    case attributeTypeShouldBeInitializeForRootAccount
    //    case accountHasAnAttribureTypeDifferentFromParent  //deprecated
    case accontAlreadyExists(name: String)
    case categoryAlreadyExists(name: String)
    case cantRemoveAccountThatUsedInTransactionItem(String)
    case cantRemoveCategoryThatUsedInTransactionItem(String)
    case creditAccountAlreadyExist(String)  //for cases when creates linked account
    case reservedName
    case accountDoesNotExist(String)
    case accumulativeAccountCannotBeHiddenWithNonZeroAmount(name: String)
    case linkedAccountHasTransactionItem(name: String)
}

extension AccountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .attributeTypeShouldBeInitializeForRootAccount:
            return NSLocalizedString("Attribute \"Type\" should be initialize for the root account", comment: "")
            
            
        //            case .accountHasAnAttribureTypeDifferentFromParent: //deprecated
        //                return NSLocalizedString("Account has an attribure type different from parent", comment: "")
        
        
        case let .accontAlreadyExists(name):
            return String(format: NSLocalizedString("Account with name \"%@\" already exist. Please use another name", comment: ""),name)
            
        case let .categoryAlreadyExists(name):
            return String(format: NSLocalizedString("Category with name \"%@\" already exist. Please use another name", comment: ""),name)
            
        case let .cantRemoveAccountThatUsedInTransactionItem(list):
            return NSLocalizedString("You can not remove this account, it should be free from transactions", comment: "")
            
        case let .cantRemoveCategoryThatUsedInTransactionItem(list):
            return NSLocalizedString("You can not remove this category, it should be free from transactions", comment: "")
            
        case let .creditAccountAlreadyExist(name):
            return String(format: NSLocalizedString("With credit card we also create associated credit account and this account \"%@\" is already exist",comment: ""), AccountsNameLocalisationManager.getLocalizedAccountName(.credits)+":"+name)
            
        case .reservedName:
            return NSLocalizedString("This is an app-reserved name. Please use another one",comment: "")
            
        case let .accountDoesNotExist(name):
            return String(format: NSLocalizedString("\"%@\" account does not exist. Please contact to support", comment: ""), name)
            
        case let .accumulativeAccountCannotBeHiddenWithNonZeroAmount(name):
            return String(format: NSLocalizedString("You cannot hide \"%@\" account with non zero amount", comment: ""), name)
            
        case let .linkedAccountHasTransactionItem(name):
            return String(format: NSLocalizedString("Linked account \"%@\" can not be removed, as it should be free from transactions", comment: ""), name)
        }
    }
    
    
    //        public var failureReason: String? {
    //
    //        }
    //        public var recoverySuggestion: String? {
    //
    //        }
}





enum CurrencyError : AppError {
    case thisCurrencyAlreadyExists
    case thisCurrencyUsedInAccounts
    case thisIsAccountingCurrency
    case thisCurrencyAlreadyUsedInTransaction
}


extension CurrencyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .thisCurrencyAlreadyExists:
            return NSLocalizedString("This currency already exists",comment: "")
        case .thisCurrencyUsedInAccounts:
            return NSLocalizedString("This currency used in accounts",comment: "")
        case .thisIsAccountingCurrency:
            return NSLocalizedString("This is accounting currency",comment: "")
        case .thisCurrencyAlreadyUsedInTransaction:
            return NSLocalizedString("Current accounting currency already used in transaction where one of accounts has different currency",comment: "")
        }
    }
}





enum BudgetError : AppError {
    case thisBadgetAlreadyExists
    case incorrectLeftOrRightBorderDate
    case incorrectLeftOrRightBorderDateInNeedGenerateBudgetsForCurrentMonthMethod
    case incorrectLeftOrRightBorderDateInAutoCreateBudgetMethod
}







enum TransactionError : AppError {
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
            return NSLocalizedString("You  have transaction in single currency. But amount in From:Account not equal to amount To:Account",comment: "")
        case .noDebitTransactionItem:
            return NSLocalizedString("Please add To:Account",comment: "")
        case .noCreditTransactionItem:
            return NSLocalizedString("Please add From:Account",comment: "")
        case .debitTransactionItemWOAccount:
            return NSLocalizedString("Please select To:Account",comment: "")
        case .creditTransactionItemWOAccount:
            return NSLocalizedString("Please select From:Account",comment: "")
        case let .multicurrencyAccount(name):
            return String(format: NSLocalizedString("Please create subaccount to \"%@\" and select them", comment: ""), name)
        }
    }
}






enum AccountWithBalanceError: AppError {
    case emptyExchangeRate
}

extension AccountWithBalanceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyExchangeRate:
            return NSLocalizedString("Please enter exchange rate",comment: "")
        }
    }
}

