//
//  MITransactionEditorAssembly.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation
import CoreData

class MITransactionEditorAssembly {

    class func configure(transactionId: UUID? = nil, context: NSManagedObjectContext) -> MITransactionEditorViewController {

        let router = MITransactionEditorRouter()
        let viewController = MITransactionEditorViewController()

        let worker = MITransactionEditor(transactionId: transactionId, context: context)

        let interactor = MITransactionEditorInteractor(worker: worker)
        let presenter = MITransactionEditorPresenter(routerInput: router, interactorInput: interactor)

        worker.delegate = presenter

        interactor.output = presenter

        presenter.viewInput = viewController

        viewController.output = presenter

        router.output = presenter
        router.viewController = viewController

        return viewController
    }
}
