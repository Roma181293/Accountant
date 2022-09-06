//
//  KeeperViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 11.06.2022.
//

import Foundation

struct KeeperViewModel {
    let id: UUID
    let name: String

    init(_ keeper: Keeper) {
        id = keeper.id
        name = keeper.name
    }
}
