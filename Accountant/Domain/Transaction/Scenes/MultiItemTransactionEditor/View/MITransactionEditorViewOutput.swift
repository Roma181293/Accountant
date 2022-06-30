//
//  MITransactionEditorViewOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import Foundation

protocol MITransactionEditorViewOutput: AnyObject {
    var isNewTransaction: Bool { get }
    var debitTransactionItems: [TransactionItemSimpleViewModel] { get }
    var creditTransactionItems: [TransactionItemSimpleViewModel] { get }
    func viewDidLoad()
    func viewWillAppear()
    func accountRequestingForTransactionItem(id: UUID)
    func setAmount(forTrasactionItem id: UUID, amount: Double)
    func setComment(_ comment: String?)
    func addDebitTransactionItem()
    func addCreditTransactionItem()
    func canBeDeleted(id: UUID) -> Bool
    func deleteTransactionItem(id: UUID)
    func setDate(_ date: Date)
    func confirm()
    func willMoveToParent()
}
