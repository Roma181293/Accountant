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

    func viewDidLoad() {
        interactorInput.provideData()
        if interactorInput.mode == .create {
            viewInput?.setTitle(NSLocalizedString("Create",
                                                  tableName: Constants.Localizable.accountEditor,
                                                  comment: ""))
        } else {
            viewInput?.configureComponentsForEditMode()
            viewInput?.setTitle(NSLocalizedString("Edit",
                                                  tableName: Constants.Localizable.accountEditor,
                                                  comment: ""))
        }
    }

    func confirmButtonDidTouch() {
        interactorInput.saveChanges()
    }

    func currencyButtonDidTouch() {
        if interactorInput.isUserHasPaidAccess {
            routerInput.presentCurrencyModule(currencyId: interactorInput.currency?.id)
        } else {
            routerInput.showPurchaseOfferModule()
        }
    }

    func keeperButtonDidTouch() {
        routerInput.presentKeeperModule(keeperId: interactorInput.keeper?.id,
                                        possibleKeeperType: interactorInput.possibleKeeperType)
    }

    func holderButtonDidTouch() {
        routerInput.presentHolderModule(holderId: interactorInput.holder?.id)
    }

    func typeButtonDidTouch() {
        routerInput.presentAccountTypeModule(accountTypeId: interactorInput.accountType.id)
    }

    func nameChangedTo(_ name: String) {
        interactorInput.setName(name)
    }

    func setBalance(_ balance: String) {
        guard let amount = Double(balance.replacingOccurrences(of: ",", with: ".")) else {return}
        interactorInput.setBalance(amount)
    }

    func setLinkedAccountBalance(_ balance: String) {
        guard let amount = Double(balance.replacingOccurrences(of: ",", with: ".")) else {return}
        interactorInput.setLinkedAccountBalance(amount)
    }

    func setExhangeRate(_ amount: String) {
        guard let amount = Double(amount.replacingOccurrences(of: ",", with: ".")) else {return}
        interactorInput.setExchangeRate(amount)
    }

    func balanceDateDidChanged(_ date: Date) {
        interactorInput.balanceDateDidChanged(date)
    }
}

extension AccountEditorPresenter: AccountEditorInteractorOutput {
    func isValidName(_ isValid: Bool) {
        viewInput?.colorNameTextFieldForState(isValid)
    }

    func nameDidSet(_ name: String) {
        viewInput?.nameDidSet(name)
    }

    func typeDidSet(_ accountType: AccountTypeViewModel?, isSingle: Bool, mode: AccountEditorService.Mode) {
        viewInput?.typeDidSet(accountType, isSingle: isSingle, mode: mode)
    }

    func currencyDidSet(_ currency: CurrencyViewModel?, accountingCurrency: CurrencyViewModel) {
        viewInput?.currencyDidSet(currency, accountingCurrency: accountingCurrency)
    }

    func holderDidSet(_ holder: HolderViewModel?) {
        viewInput?.holderDidSet(holder)
    }

    func keeperDidSet(_ keeper: KeeperViewModel?) {
        viewInput?.keeperDidSet(keeper)
    }

    func rateDidSet(_ rate: Double?) {
        viewInput?.rateDidSet(rate)
    }

    func errorHandler(_ error: Error) {
        routerInput.showError(error: error)
    }

    func closeModule() {
        routerInput.closeModule()
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

    var accountTypeDelegate: AccountTypeReciverDelegate? {
        return interactorInput
    }
}
