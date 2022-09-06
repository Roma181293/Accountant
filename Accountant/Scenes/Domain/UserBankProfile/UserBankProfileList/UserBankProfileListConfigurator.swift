//
//  UserBankProfileListConfigurator.swift
//  Accountant
//
//  Created by Roman Topchii on 18.05.2022.
//

import Foundation

protocol UserBankProfileListConfiguratorProtocol: AnyObject {
    func configure(with viewController: UserBankProfileListViewController)
}

class UserBankProfileListConfigurator: UserBankProfileListConfiguratorProtocol {
    func configure(with viewController: UserBankProfileListViewController) {
        let presenter = UserBankProfileListPresenter(view: viewController)
        let interactor = UserBankProfileListInteractor(presenter: presenter)
        let router = UserBankProfileListRouter(viewController: viewController)

        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
