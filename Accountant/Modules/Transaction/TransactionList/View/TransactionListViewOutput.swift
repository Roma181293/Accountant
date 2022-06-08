//
//  TransactionListViewOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import UIKit

protocol TransactionListViewOutput: AnyObject {
    func duplicateTransactionAction(at indexPath: IndexPath) -> UIContextualAction
    func deleteTransactionAction(at indexPath: IndexPath) -> UIContextualAction
    func search(text: String)
    func createTransaction()
    func editTransaction(at indexPath: IndexPath)

    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func transactionAt(_ indexPath: IndexPath) -> TransactionViewModel

    func proAcceessButtonDidClick()
    func syncStatmentsButtonDidClick()
    func viewWillAppear()
}
