//
//  Extension Notification.swift
//  Accountant
//
//  Created by Roman Topchii on 03.09.2021.
//

import Foundation

extension Notification.Name {
    static let environmentDidChange = Notification.Name("environmentDidChange")

    static let persistentStoreWillLoad = Notification.Name("CoreDataStack_persistentStoreWillLoad")
    static let persistentStoreDidLoad = Notification.Name("CoreDataStack_persistentStoreDidLoad")

    static let receivedProAccessData = Notification.Name("receivedProAccessData")

}
