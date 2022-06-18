//
//  AccountEditorAssembly.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

class AccountEditorAssembly {
    class func configure(parentAccountId: UUID) -> AccountEditorViewController {

        let service = AccountEditorService(persistentContainer: CoreDataStack.shared.persistentContainer,
                                           parentAccountId: parentAccountId)
        
        let router = AccountEditorRouter()
        let viewController = AccountEditorViewController()
        let interactor = AccountEditorInteractor(service: service)
        let presenter = AccountEditorPresenter(routerInput: router, interactorInput: interactor)

        service.delegate = presenter
        interactor.output = presenter

        presenter.viewInput = viewController

        viewController.output = presenter

        router.output = presenter
        router.viewController = viewController

        return viewController
    }
}
