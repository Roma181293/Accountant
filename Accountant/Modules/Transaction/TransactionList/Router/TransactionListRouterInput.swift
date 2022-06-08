//
//  TransactionListRouterInput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import UIKit

protocol TransactionListRouterInput: AnyObject {
    func openMITransactionEditorModule(transactionId: UUID?)
    func openSimpleTransactionEditorModule(transactionId: UUID?)
    func deleteAlertFor(indexPath: IndexPath)
    func showPurchaseOfferVC()
    func showError(error: Error)
}
