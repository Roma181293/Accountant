//
//  MonobankConfigurator.swift
//  Accountant
//
//  Created by Roman Topchii on 14.05.2022.
//

import Foundation

protocol MonobankUBPConfiguratorProtocal: AnyObject {
    func configure(with viewController: MonobankUBPViewController)
}

class MonobankUBPConfigurator: MonobankUBPConfiguratorProtocal {
    func configure(with viewController: MonobankUBPViewController) {
        let presenter = MonobankUBPPresenter(view: viewController)
        let interactor = MonobankUBPInteractor(presenter: presenter)
        let router = MonobankUBPRouter(viewController: viewController)

        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
