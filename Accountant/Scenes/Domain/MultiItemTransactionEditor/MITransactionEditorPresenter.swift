//
//  MITransactionEditorPresenter.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import UIKit

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
    
    var accountingCurrencyCode: String {
        interactorInput.accountingCurrencyCode
    }
    
    private var transactionItems: [TransactionItemSimpleViewModel] = [] {
        didSet {
            viewInput?.reloadData()
        }
    }
    private var transactionItemForAccountSpecifyigId: UUID = UUID()

    required init(routerInput: MITransactionEditorRouterInput, interactorInput: MITransactionEditorInteractorInput) {
        self.routerInput = routerInput
        self.interactorInput = interactorInput
    }

    var debitTransactionItems: [TransactionItemSimpleViewModel] {
        return transactionItems.filter({ $0.type == .debit }).sorted(by: {$0.createDate > $1.createDate})
    }
    var creditTransactionItems: [TransactionItemSimpleViewModel] {
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
        routerInput.openAccountNavigationScene(with: self,
                               parent: interactorInput.rootAccountFor(transactionItemId: id),
                               excludeAccountList: interactorInput.usedAccountList())
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double, amountInAccountingCurrency: Double) {
        interactorInput.setAmount(forTrasactionItem: id, amount: amount, amountInAccountingCurrency: amountInAccountingCurrency)
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
        do {
            try interactorInput.setDate(date)
        } catch let error {
            routerInput.showError(error)
        }
    }

    func willMoveToParent() {
        interactorInput.cleanUnusedData()
    }

    func confirm() {
        do {
            if interactorInput.transactionStatus != .preDraft {
                if !interactorInput.isNewTransaction && interactorInput.hasChanges {
                    routerInput.showSaveAlert()
                } else {
                    try interactorInput.save()
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
        var result: [TransactionItemSimpleViewModel] = []
        transactionItems.forEach({
            result.append(TransactionItemSimpleViewModel(transactionItem: $0))
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
        if transactionItems.filter({$0.type == .debit}).count > 1
            && transactionItems.filter({$0.type == .credit}).count >= 1 {
            viewInput?.creditAddButtonIsHidden = true
        } else {
            viewInput?.creditAddButtonIsHidden = false
        }
        if transactionItems.filter({$0.type == .credit}).count > 1
            && transactionItems.filter({$0.type == .debit}).count >= 1 {
            viewInput?.debitAddButtonIsHidden = true
        } else {
            viewInput?.debitAddButtonIsHidden = false
        }
    }

    func disableEdit() {
        viewInput?.disableUserInteractionForUI()
    }
}

// MARK: - MITransactionEditorRouterOutput
extension MITransactionEditorPresenter: MITransactionEditorRouterOutput {
    func confirmActionDidClick() {
        do {
            try self.interactorInput.save()
        } catch {
            routerInput.showError(error)
        }
        self.routerInput.popViewController()
    }
}
