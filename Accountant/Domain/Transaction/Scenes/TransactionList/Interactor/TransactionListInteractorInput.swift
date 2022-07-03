//
//  TransactionListInteractorInput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import CoreData

protocol TransactionListInteractorInput: AnyObject {
    func viewWillAppear()
    func isMITransactionModeOn() -> Bool
    func hasActiveBankAccounts() -> Bool
    func activeEnvironment() -> Environment
    func activeContext() -> NSManagedObjectContext
    func userHasPaidAccess() -> Bool
    func loadStatmentsData()

    func canDuplicateTransaction() -> Bool
    func duplicateTransaction(at indexPath: IndexPath)
    func deleteTransaction(at indexPath: IndexPath)
    func search(text: String)

    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func transactionAt(_ indexPath: IndexPath) -> TransactionViewModel
}
