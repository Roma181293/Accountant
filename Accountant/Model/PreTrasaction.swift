//
//  PreTrasaction.swift
//  Accounting
//
//  Created by Roman Topchii on 24.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

class PreTransaction {
    var date : Date?
    var debit : Account?
    var credit : Account?
    var debitAmount : Double?
    var creditAmount : Double?
    var memo : String?

    var isReadyToCreateTransaction: Bool {
        if date == nil {
            return false
        }
        if debit == nil {
            return false
        }
        if credit == nil {
            return false
        }
        if debitAmount == nil {
            return false
        }
        if creditAmount == nil {
            return false
        }
        return true
    }
    func printPreTransaction() {
      //  print(transactionDate, debitAccount?.nativeId, creditAccount?.nativeId, amountInDebitCurrency, amountInCreditCurrency, memo, isReadyToCreateTransaction)
    }



}
