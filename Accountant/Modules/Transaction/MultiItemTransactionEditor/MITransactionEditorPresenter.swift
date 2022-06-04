//
//  MITransactionEditorPresenter.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import UIKit

struct TransactionItemViewModel {
    let id: UUID
    let path: String
    let amount: String
    let type: TransactionItem.TypeEnum
    let createDate: Date
}

class MITransactionEditorPresenter: MITransactionEditorViewOutput {

    weak var viewInput: MITransactionEditorViewInput? {
        didSet {
            viewInput?.configureView()
        }
    }
    var interactorInput: MITransactionEditorInteractorInput
    var routerInput: MITransactionEditorRouterInput

    var isNewTransaction: Bool {
        return interactorInput.isNewTransaction
    }
    private var transactionItems: [TransactionItemViewModel] = [] {
        didSet {
            viewInput?.reloadData()
        }
    }
    private var transactionItemForAccountSpecifyigId: UUID = UUID()

    required init(routerInput: MITransactionEditorRouterInput, interactorInput: MITransactionEditorInteractorInput) {
        self.routerInput = routerInput
        self.interactorInput = interactorInput
    }

    var debitTransactionItems: [TransactionItemViewModel] {
        return transactionItems.filter({ $0.type == .debit }).sorted(by: {$0.createDate > $1.createDate})
    }
    var creditTransactionItems: [TransactionItemViewModel] {
        return transactionItems.filter({ $0.type == .credit }).sorted(by: {$0.createDate > $1.createDate})
    }

    func viewDidLoad() {
        interactorInput.fetchData()
    }

    func viewWillAppear() {
        interactorInput.fetchData()
    }

    func accountRequestingForTransactionItem(id: UUID) {
        transactionItemForAccountSpecifyigId = id
        routerInput.getAccount(with: self,
                               parent: interactorInput.rootAccountFor(transactionItemId: id),
                               excludeAccountList: interactorInput.usedAccountList())
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double) {
        interactorInput.setAmount(forTrasactionItem: id, amount: amount)
    }

    func setComment(_ comment: String?) {
        interactorInput.setComment(comment)
    }

    func addDebitTransactionItem() {
        interactorInput.addEmptyTransactionItem(type: .debit)
    }

    func addCreditTransactionItem() {
        interactorInput.addEmptyTransactionItem(type: .credit)
    }

    func canBeDeleted(id: UUID) -> Bool {
        guard let tranItemType = transactionItems.filter({$0.id == id}).first?.type else {return false}
        if transactionItems.filter({$0.type == tranItemType}).count == 1 {
            return false
        }
        return true
    }

    func deleteTransactionItem(id: UUID) {
        interactorInput.deleteTransactionItem(id: id)
    }

    func setDate(_ date: Date) {
        interactorInput.transactionDate = date
    }

    func willMoveToParent() {
        interactorInput.cleanUnusedData()
    }

    func confirm() {
        do {
            try interactorInput.validateTransaction()
            if interactorInput.transactionStatus != .preDraft {
                if !interactorInput.isNewTransaction && interactorInput.hasChanges {
                    routerInput.showSaveAlert()
                } else {
                    interactorInput.save()
                    routerInput.popViewController()
                }
            } else {
                routerInput.popViewController()
            }
        } catch let error {
            routerInput.showError(error)
        }
    }
}

// MARK: - AccountRequestor
extension MITransactionEditorPresenter: AccountRequestor {
    func setAccount(_ account: Account) {
        interactorInput.setAccount(account, forTransactionItem: transactionItemForAccountSpecifyigId)
    }
}

// MARK: - MITransactionEditorInteractorOutput
extension MITransactionEditorPresenter: MITransactionEditorInteractorOutput {
    func fetched(transactionItems: [TransactionItem]) {
        var result: [TransactionItemViewModel] = []
        transactionItems.forEach({
            let path = $0.account?.path ?? NSLocalizedString("Account/Category",
                                                             tableName: Constants.Localizable.mITransactionEditor,
                                                             comment: "")
            result.append(TransactionItemViewModel(id: $0.id,
                                                   path: path,
                                                   amount: ($0.amount == 0) ? "" : String($0.amount),
                                                   type: $0.type,
                                                   createDate: $0.createDate ?? Date()))
        })
        print(result)
        self.transactionItems = result

        configureAddTransactionItemButtons()
    }

    func fetched(date: Date) {
        viewInput?.setDate(date)
    }

    func fetched(comment: String?) {
        viewInput?.setComment(comment)
    }

    private func configureAddTransactionItemButtons() {
        if transactionItems.filter({$0.type == .debit}).count > 1 {
            viewInput?.creditAddButtonIsHidden = true
        } else {
            viewInput?.creditAddButtonIsHidden = false
        }
        if transactionItems.filter({$0.type == .credit}).count > 1 {
            viewInput?.debitAddButtonIsHidden = true
        } else {
            viewInput?.debitAddButtonIsHidden = false
        }
    }
}

// MARK: - MITransactionEditorRouterOutput
extension MITransactionEditorPresenter: MITransactionEditorRouterOutput {
    func confirmActionDidClick() {
        self.interactorInput.save()
        self.routerInput.popViewController()
    }
}
