//
//  MITransactionEditorRouterInput.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import UIKit

protocol MITransactionEditorRouterInput: AnyObject {
    func openAccountNavigationScene(with delegate: AccountRequestor, parent: Account?, excludeAccountList: [Account])
    func popViewController()
    func dismiss()
    func showSaveAlert()
    func showError(_ error: Error)
}
