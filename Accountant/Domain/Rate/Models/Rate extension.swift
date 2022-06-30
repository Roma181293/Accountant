//
//  Rate extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation

extension Rate {
    
    func delete() {
        managedObjectContext?.delete(self)
    }

    enum Error: AppError {
        case alreadyExist
    }
}
