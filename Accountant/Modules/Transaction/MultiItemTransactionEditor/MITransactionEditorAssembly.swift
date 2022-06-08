//
//  MITransactionEditorAssembly.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation

class MITransactionEditorAssembly {
    
    class func configure(transactionId: UUID? = nil) -> MITransactionEditorViewController {

        let transaction = Transaction.getTransactionFor(id: transactionId ?? UUID(),
                                                        context: CoreDataStack.shared.persistentContainer.viewContext)

        let router = MITransactionEditorRouter()
        let viewController = MITransactionEditorViewController()
        let interactor = MITransactionEditorInteractor(transaction: transaction)
        let presenter = MITransactionEditorPresenter(routerInput: router, interactorInput: interactor)

        interactor.output = presenter

        presenter.viewInput = viewController

        viewController.output = presenter

        router.output = presenter
        router.viewController = viewController

        return viewController
    }
}
