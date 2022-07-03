//
//  TransactionListRouterInput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import CoreData

protocol TransactionListRouterInput: AnyObject {
    func openMITransactionEditorModule(transactionId: UUID?, context: NSManagedObjectContext)
    func deleteAlertFor(indexPath: IndexPath)
    func showPurchaseOfferModule()
    func showError(error: Error)
}
