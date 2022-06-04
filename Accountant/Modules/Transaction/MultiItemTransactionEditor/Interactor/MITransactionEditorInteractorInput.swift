//
//  MITransactionEditorInteractorInput.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import Foundation

protocol MITransactionEditorInteractorInput: AnyObject {
    var isNewTransaction: Bool { get }
    var transactionDate: Date { get set }
    var transactionStatus: Transaction.Status { get }
    var hasChanges: Bool { get }
    func fetchData()
    func addEmptyTransactionItem(type: TransactionItem.TypeEnum)
    func deleteTransactionItem(id: UUID)
    func setAccount(_ account: Account, forTransactionItem id: UUID)
    func setAmount(forTrasactionItem id: UUID, amount: Double)
    func setComment(_ comment: String?)
    func usedAccountList() -> [Account]
    func rootAccountFor(transactionItemId: UUID) -> Account?
    func validateTransaction() throws
    func save()
    func cleanUnusedData()
}
