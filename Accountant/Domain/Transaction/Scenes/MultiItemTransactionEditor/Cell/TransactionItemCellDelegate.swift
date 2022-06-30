//
//  TransactionItemCellDelegate.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import Foundation

protocol TransactionItemCellDelegate: AnyObject {
    func accountRequestingForTransactionItem(id: UUID)
    func setAmount(forTrasactionItem id: UUID, amount: Double)
}
