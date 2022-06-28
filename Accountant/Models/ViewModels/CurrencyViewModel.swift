//
//  CurrencyViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 11.06.2022.
//

import Foundation

struct CurrencyViewModel {
    let id: UUID
    let name: String?
    let code: String
    let isAccounting: Bool

    init (_ currency: Currency) {
        self.id = currency.id
        self.name = currency.name
        self.code = currency.code
        self.isAccounting = currency.isAccounting
    }
}
