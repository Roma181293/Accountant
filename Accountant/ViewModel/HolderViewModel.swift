//
//  HolderViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 11.06.2022.
//

import Foundation

struct HolderViewModel {
    let id: UUID
    let name: String
    let icon: String

    init(_ holder: Holder) {
        id = holder.id
        name = holder.name
        icon = holder.icon
    }
}
