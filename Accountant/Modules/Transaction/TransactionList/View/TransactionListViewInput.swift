//
//  TransactionListViewInput.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation

protocol TransactionListViewInput: AnyObject {
    func configureView()
    func reloadData()
    func drawProAccessButton(isHidden: Bool)
    func drawSyncStatmentsButton(isHidden: Bool)
    func drawTabBarBadge(isHidden: Bool)
    
}
