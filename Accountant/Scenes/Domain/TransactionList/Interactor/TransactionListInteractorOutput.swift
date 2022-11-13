//
//  TransactionListInteractorOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation

protocol TransactionListInteractorOutput: AnyObject {
    func didFetchTransactions()
    func showError(error: Error)
    func environmentDidChange(environment: Environment)
}
