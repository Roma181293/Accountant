//
//  Exchange extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

extension Exchange {

    var ratesList: [Rate] {
        return Array(rates)
    }

    func delete() {
        self.ratesList.forEach({ rate in
            rate.delete()
        })
        managedObjectContext?.delete(self)
    }

    enum Error: AppError {
        case alreadyExist(date: Date)
        case baseCurrencyCodeNotFound
    }
}
