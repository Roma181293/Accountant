//
//  MITransactionEditorViewDelegate.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import Foundation

protocol MITransactionEditorViewDelegate: AnyObject {
    func changeDate(_ date: Date)
    func debitAddButtonDidClick()
    func creditAddButtonDidClick()
    func confirm()
}
