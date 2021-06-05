//
//  Subscription struct.swift
//  Accounting
//
//  Created by Roman Topchii on 08.02.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation

enum EntitlementPacketName: String {
    case pro = "pro"
    case none = "none"
}

struct Entitlement {
    let name : EntitlementPacketName
    let expirationDate : Date?
    let lastUpdate : Date
    
    init(name : EntitlementPacketName, expirationDate : Date?){
        self.name = name
        self.expirationDate = expirationDate
        lastUpdate = Date()
    }
    
    init(name : EntitlementPacketName, expirationDate : Date?, lastUpdate: Date){
        self.name = name
        self.expirationDate = expirationDate
        self.lastUpdate = lastUpdate
    }
}
