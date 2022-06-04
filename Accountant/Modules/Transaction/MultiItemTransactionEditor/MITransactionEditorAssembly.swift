//
//  MITransactionEditorAssembly.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation

class MITransactionEditorAssembly {
    
    class func configure(transaction: Transaction? = nil) -> MITransactionEditorViewController {

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
