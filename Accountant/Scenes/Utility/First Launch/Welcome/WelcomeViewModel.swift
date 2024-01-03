//
//  WelcomeViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 26.11.2023.
//

import Foundation

class WelcomeViewModel {

    func switchToTestData() throws {
        CoreDataStack.shared.switchPersistentStore(.test)
        try CoreDataStack.shared.restorePersistentStore(.test)
        try SeedDataService.addTestData(persistentContainer: CoreDataStack.shared.persistentContainer)
    }
}
