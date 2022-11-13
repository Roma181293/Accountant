//
//  TransactionListRouterOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation

protocol TransactionListRouterOutput: AnyObject {
    func deleteActionDidClickFor(indexPath: IndexPath)
}
