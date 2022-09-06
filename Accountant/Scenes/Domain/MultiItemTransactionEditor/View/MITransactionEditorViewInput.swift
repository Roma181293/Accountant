//
//  MITransactionEditorViewInput.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import Foundation

protocol MITransactionEditorViewInput: AnyObject {
    var creditAddButtonIsHidden: Bool { get set }
    var debitAddButtonIsHidden: Bool { get set }
    func configureView()
    func reloadData()
    func setDate(_ date: Date)
    func setMinDate(_ date: Date?)
    func setComment(_ comment: String?)
    func disableUserInteractionForUI()
}
