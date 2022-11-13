//
//  MonobankUBPPresenter.swift
//  Accountant
//
//  Created by Roman Topchii on 14.05.2022.
//

import Foundation

protocol MonobankUBPPresenterProtocol: AnyObject {
    var router: MonobankUBPRouterProtocol! {get set}
    func configureView()
    func getDataButtonClicked(with token: String)
    func holderButtonClicked()
    func confirmButtonClicked()
    func userInfoDidLoad()
    func accountsDidSaved()
    func numberOfBankAccounts() -> Int
    func accountInfoAt(_ index: Int) -> MBAccountInfo
    func showError(_ error: Error)
    func showWarning(message: String)
    func lockGetDataButton()
    func unlockGetDataButton()
    func showHolderComponent()
    func openAboutApi()
    func openGetToken()
}

class MonobankUBPPresenter: MonobankUBPPresenterProtocol {

    weak var view: MonobankUBPView!
    var interactor: MonobankUBPInteractorProtocol!
    var router: MonobankUBPRouterProtocol!

    var holder: Holder? {
        get {
            return interactor.holder
        }
        set {
            if let value = newValue {
                interactor.holder = value
                view.setHolderButtonTitle(with: value.icon + " - " + value.name)
            } else {
                view.setHolderButtonTitle(with: "")
            }
        }
    }

    required init(view: MonobankUBPViewController) {
        self.view = view
    }

    func configureView() {
        view.configureView()
    }

    func getDataButtonClicked(with token: String) {
        view.setHolderComponentIsHidden(true)
        interactor.loadMBUserInfo(for: token)
    }

    func holderButtonClicked() {
        router.showHolderList(with: holder, delegate: self)
    }

    func confirmButtonClicked() {
        interactor.createAccounts()
    }

    func userInfoDidLoad() {
        guard let userInfo = interactor.userInfo else {return}
        if userInfo.isAnyAccountToAdd() {
            view.setConfirmButtonIsHidden(false)
        } else {
            view.setConfirmButtonIsHidden(true)
        }
        view.tableViewReloadData()
    }

    func accountsDidSaved() {
        router.close()
    }

    func numberOfBankAccounts() -> Int {
        return interactor.userInfo?.accounts.count ?? 0
    }

    func accountInfoAt(_ index: Int) -> MBAccountInfo {
        return interactor.userInfo!.accounts[index]
    }

    func showError(_ error: Error) {
        router.showError(error)
    }

    func showWarning(message: String) {
        router.showWarning(message)
    }

    func lockGetDataButton() {
        view.setGetDataButtonIsUserInteractionEnabled(false)
    }

    func unlockGetDataButton() {
        view.setGetDataButtonIsUserInteractionEnabled(true)
    }

    func showHolderComponent() {
        view.setHolderComponentIsHidden(false)
        if let holder = holder {
            view.setHolderButtonTitle(with: holder.icon + " - " + holder.name)
        } else {
            view.setHolderButtonTitle(with: "")
        }
    }

    func openAboutApi() {
        guard let url = URL(string: Constants.URL.monoAPIDoc) else {return}
        router.openWeb(url: url)
    }

    func openGetToken() {
        guard let url = URL(string: Constants.URL.monoToken) else {return}
        router.openWeb(url: url)
    }
}

extension MonobankUBPPresenter: HolderReceiverDelegate {
    func setHolder(_ selectedHolder: Holder?) {
        holder = selectedHolder
    }
}
