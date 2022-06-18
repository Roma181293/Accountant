//
//  AccountEditorPresenter.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

class AccountEditorPresenter {

    // MARK: Properties
    weak var viewInput: AccountEditorViewInput?
    var interactorInput: AccountEditorInteractorInput
    var routerInput: AccountEditorRouterInput

    required init(routerInput: AccountEditorRouterInput, interactorInput: AccountEditorInteractorInput) {
        self.routerInput = routerInput
        self.interactorInput = interactorInput
    }

}

extension AccountEditorPresenter: AccountEditorViewOutput {
    func confirmButtonDidTouch() {

    }

    func currencyButtonDidTouch() {
        routerInput.presentCurrencyModule(currencyId: interactorInput.currencyId)
    }

    func keeperButtonDidTouch() {
        routerInput.presentKeeperModule(keeperId: interactorInput.keeperId)
    }

    func holderButtonDidTouch() {
        routerInput.presentHolderModule(holderId: interactorInput.holderId)
    }

    func typeButtonDidTouch() {

    }

    func nameChangedTo(_ name: String) {
        interactorInput.setName(name)
    }

    func balanceChangedTo(_ balance: String) {
        guard let amount = Double(balance.replacingOccurrences(of: ",", with: ".")) else {return}
        interactorInput.setBalance(amount)
    }

    func creditLimitChangedTo(_ creditLimit: String) {
        guard let amount = Double(creditLimit.replacingOccurrences(of: ",", with: ".")) else {return}
        interactorInput.setLinkedAccountBalance(amount)
    }

    func exchangeRateChangedTo(_ exchangeRate: String) {
        guard let amount = Double(exchangeRate.replacingOccurrences(of: ",", with: ".")) else {return}
        interactorInput.setExchangeRate(amount)
    }
}

extension AccountEditorPresenter: AccountEditorInteractorOutput {
    func isValidName(_ isValid: Bool) {
        if isValid {
            viewInput?.colorNameTextField(.systemBackground)
        } else {
            viewInput?.colorNameTextField(.systemPink.withAlphaComponent(0.1))
        }
    }

    func typeDidSet(_ accountType: AccountTypeViewModel?) {

    }

    func currencyDidSet(_ currency: CurrencyViewModel?) {
        viewInput?.currencyDidSet(currency)
    }

    func holderDidSet(_ holder: HolderViewModel?) {
        viewInput?.holderDidSet(holder)
    }

    func keeperDidSet(_ keeper: KeeperViewModel?) {
        viewInput?.keeperDidSet(keeper)
    }

    func currencyIsAccounting(_ isAccounting: Bool) {

    }
    func errorHandler(_ error: Error) {
        print(error.localizedDescription)
    }
}

extension AccountEditorPresenter: AccountEditorRouterOutput {
    var keeperDelegate: KeeperReceiverDelegate? {
        return interactorInput
    }

    var holderDelegate: HolderReceiverDelegate? {
        return interactorInput
    }

    var currencyDelegate: CurrencyReceiverDelegate? {
        return interactorInput
    }
}
