//
//  AccountEditorRouterOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

protocol AccountEditorRouterOutput: AnyObject {
    var keeperDelegate: KeeperReceiverDelegate? { get }
    var holderDelegate: HolderReceiverDelegate? { get }
    var currencyDelegate: CurrencyReceiverDelegate? { get }
    var accountTypeDelegate: AccountTypeReciverDelegate? { get }
}
