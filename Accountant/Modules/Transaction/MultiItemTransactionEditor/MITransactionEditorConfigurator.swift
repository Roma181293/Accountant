//
//  MITransactionEditorConfigurator.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation

protocol MITransactionEditorConfiguratorProtocol: AnyObject {
    static func configure(router: MITransactionEditorRouter) -> MITransactionEditorViewController
}

class MITransactionEditorConfigurator: MITransactionEditorConfiguratorProtocol {
    static func configure(router: MITransactionEditorRouter) -> MITransactionEditorViewController {
        let viewController = MITransactionEditorViewController()
        let interactor = MITransactionEditorInteractor(transaction: router.transaction)
        let presenter = MITransactionEditorPresenter(router: router, interactor: interactor)
        interactor.presenter = presenter
        presenter.view = viewController
        viewController.presenter = presenter
        return viewController
    }
}
