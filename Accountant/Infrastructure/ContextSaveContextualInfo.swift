//
//  ContextSaveContextualInfo.swift
//  Accountant
//
//  Created by Roman Topchii on 05.11.2023.
//

import Foundation

/**
 Contextual information for handling Core Data context save errors.
 */
enum ContextSaveContextualInfo: String {
    case addKeeper = "adding Keeper"
    case renameKeeper = "renaming Keeper"
    case deleteKeeper = "deleting Keeper"
    case addHolder = "adding Holder"
    case editHolder = "editing Holder"
    case deleteHolder = "deleting Holder"
    case addCurrency = "adding Currency"
    case setAccountingCurrency = "setting accounting Currency"
    case addAccount = "adding Account"
    case renameAccount = "renaming Account"
    case changeAccountActiveStatus = "changing account active status"
    case deleteAccount = "deleting Account"
    case duplicateTransaction = "duplicating Transaction"
    case deleteTransaction = "deleting Transaction"
    case applyApprovedTransactions = "applying an approved Transactions"
    case archivingTransactions = "archiving Transactions"
    case unarchivingTransactions = "unarchiving Transactions"
    case deleteUserBankProfile = "deleting User Bank Profile"
    case changeUBPActiveStatus = "changing User Bank Profile active status"
    case addMultiItemTransaction = "adding Multi Item Transaction"
    case editMultiItemTransaction = "editing Multi Item Transaction"
}
