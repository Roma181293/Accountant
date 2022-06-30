//
//  MITransactionEditorInteractorOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import Foundation

protocol MITransactionEditorInteractorOutput: AnyObject {
    func fetched(transactionItems: [TransactionItem])
    func fetched(date: Date)
    func fetched(comment: String?)
}
