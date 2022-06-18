//
//  AccountTypeViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 10.06.2022.
//

import Foundation

struct AccountTypeViewModel {
    let id: UUID
    let name: String

    init (_ accountType: AccountType) {
        self.id = accountType.id
        self.name = accountType.name
    }
}
