//
//  AccountEditorInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation
import Purchases

class AccountEditorInteractor: AccountEditorInteractorInput {

    let service: AccountEditorService
    weak var output: AccountEditorInteractorOutput?

    var currency: CurrencyViewModel? {
        return service.currency
    }

    var keeper: KeeperViewModel? {
        return service.keeper
    }

    var possibleKeeperType: AccountType.KeeperGroup {
        return service.possibleKeeperType()
    }

    var holder: HolderViewModel? {
        return service.holder
    }

    var accountType: AccountTypeViewModel {
        return service.parentAccountType
    }

    var canBeRenamed: Bool {
        service.canBeRenamed
    }

    var mode: AccountEditorService.Mode {
        return service.mode
    }

    private(set) var isUserHasPaidAccess: Bool = false

    init(service: AccountEditorService) {
        self.service = service

        reloadProAccessData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    @objc private func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }

    func provideData() {
        service.provideData()
    }

    func setAccountType(_ accountTypeId: UUID) {
       try? service.setType(accountTypeId)
    }

    func setCurrency(_ selectedCurrency: Currency) {
        service.setCurrency(selectedCurrency.id)
    }

    func setKeeper(_ selectedKeeper: Keeper?) {
        service.setKeeper(selectedKeeper?.id)
    }

    func setHolder(_ selectedHolder: Holder?) {
        service.setHolder(selectedHolder?.id)
    }

    func setName(_ name: String) {
        service.setName(name)
    }

    func setBalance(_ balance: Double) {
        service.setBalance(balance)
    }

    func setLinkedAccountBalance(_ balance: Double) {
        service.setLinkedAccountBalance(balance)
    }

    func setExchangeRate(_ exchangeRate: Double) {
        service.setRate(exchangeRate)
    }

    func balanceDateDidChanged(_ date: Date) {
        service.setBalanceDate(date)
    }

    func saveChanges() {
        service.saveChanges(compliting: {
            self.output?.closeModule()
        })
    }
}
