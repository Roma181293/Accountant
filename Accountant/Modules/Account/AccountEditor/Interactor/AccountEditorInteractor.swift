//
//  AccountEditorInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

class AccountEditorInteractor: AccountEditorInteractorInput {

    let service: AccountEditorService
    weak var output: AccountEditorInteractorOutput?

    var currencyId: UUID {
        return service.currencyId
    }
    var keeperId: UUID? {
        return service.keeperId
    }
    var holderId: UUID? {
        return service.holderId
    }

    init(service: AccountEditorService) {
        self.service = service
    }

    func setCurrency(_ selectedCurrency: Currency) {
        service.currencyId = selectedCurrency.id
    }

    func setKeeper(_ selectedKeeper: Keeper?) {
        service.keeperId = selectedKeeper?.id
    }

    func setHolder(_ selectedHolder: Holder?) {
        service.holderId = selectedHolder?.id
    }

    func setName(_ name: String) {
        service.setName(name)
    }
    
    func setBalance(_ balance: Double) {
        service.balance = balance
    }

    func setLinkedAccountBalance(_ balance: Double) {
        service.linkedAccountBalance = balance
    }

    func setExchangeRate(_ exchangeRate: Double) {
        service.rate = exchangeRate
    }
}
