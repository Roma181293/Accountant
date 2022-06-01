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

protocol MITransactionEditorPresenterInput: AnyObject {
    var isNewTransaction: Bool { get }
    var debitTransactionItems: [TransactionItemViewModel] { get }
    var creditTransactionItems: [TransactionItemViewModel] { get }
    func viewDidLoad()
    func viewWillAppear()
    func accountRequestingForTransactionItem(id: UUID)
    func setAmount(forTrasactionItem id: UUID, amount: Double)
    func setComment(_ comment: String?)
    func addDebitTransactionItem()
    func addCreditTransactionItem()
    func canBeDeleted(id: UUID) -> Bool
    func deleteTransactionItem(id: UUID)
    func setDate(_ date: Date)
    func confirm()
    func willMoveToParent()
}

class MITransactionEditorPresenter: MITransactionEditorPresenterInput {

    weak var view: MITransactionEditorViewController? {
        didSet {
            view?.configureView()
        }
    }
    var interactor: MITransactionEditorInteractorInput!
    var router: MITransactionEditorRouterProtocol!

    var isNewTransaction: Bool {
        return interactor.isNewTransaction
    }
    private var transactionItems: [TransactionItemViewModel] = [] {
        didSet {
            view?.debitTableView.reloadData()
            view?.creditTableView.reloadData()
        }
    }
    private var transactionItemForAccountSpecifyigId: UUID = UUID()

    required init(router: MITransactionEditorRouterProtocol, interactor: MITransactionEditorInteractorInput) {
        self.router = router
        self.interactor = interactor
    }

    var debitTransactionItems: [TransactionItemViewModel] {
        return transactionItems.filter({ $0.type == .debit }).sorted(by: {$0.createDate > $1.createDate})
    }
    var creditTransactionItems: [TransactionItemViewModel] {
        return transactionItems.filter({ $0.type == .credit }).sorted(by: {$0.createDate > $1.createDate})
    }

    func viewDidLoad() {
        interactor.fetchData()
    }

    func viewWillAppear() {
        interactor.fetchData()
    }

    func accountRequestingForTransactionItem(id: UUID) {
        guard let view = view else {return}
        transactionItemForAccountSpecifyigId = id
        router.getAccount(with: self,
                          delegate: view,
                          parent: interactor.rootAccountFor(transactionItemId: id),
                          excludeAccountList: interactor.usedAccountList())
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double) {
        interactor.setAmount(forTrasactionItem: id, amount: amount)
    }

    func setComment(_ comment: String?) {
        interactor.setComment(comment)
    }

    func addDebitTransactionItem() {
        interactor.addEmptyTransactionItem(type: .debit)
    }

    func addCreditTransactionItem() {
        interactor.addEmptyTransactionItem(type: .credit)
    }

    func canBeDeleted(id: UUID) -> Bool {
        guard let tranItemType = transactionItems.filter({$0.id == id}).first?.type else {return false}
        if transactionItems.filter({$0.type == tranItemType}).count == 1 {
            return false
        }
        return true
    }

    func deleteTransactionItem(id: UUID) {
        interactor.deleteTransactionItem(id: id)
    }

    func setDate(_ date: Date) {
        interactor.transactionDate = date
    }

    func willMoveToParent() {
        interactor.cleanUnusedData()
    }

    func confirm() {
        do {
            try interactor.validateTransaction()
            if interactor.transactionStatus != .preDraft {
                if !interactor.isNewTransaction && interactor.hasChanges {
                    let saveTitle = NSLocalizedString("Save", tableName: Constants.Localizable.mITransactionEditorVC,
                                                      comment: "")
                    let message = NSLocalizedString("Save changes?",
                                                    tableName: Constants.Localizable.mITransactionEditorVC,
                                                    comment: "")
                    let alert = UIAlertController(title: saveTitle,
                                                  message: message,
                                                  preferredStyle: .alert)
                    let yesTitle = NSLocalizedString("Yes", tableName: Constants.Localizable.mITransactionEditorVC,
                                                     comment: "")
                    alert.addAction(UIAlertAction(title: yesTitle,
                                                  style: .default, handler: {(_) in
                        self.interactor.save()
                        self.view?.navigationController?.popViewController(animated: true)
                    }))
                    let cancelTitle = NSLocalizedString("Cancel",
                                                        tableName: Constants.Localizable.mITransactionEditorVC,
                                                        comment: "")
                    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
                    view?.present(alert, animated: true, completion: nil)
                } else {
                    self.interactor.save()
                    self.view?.navigationController?.popViewController(animated: true)
                }
            } else {
                self.view?.navigationController?.popViewController(animated: true)
            }
        } catch let error {
            guard let view = view else {return}
            router.showError(error, in: view)
        }
    }
}

extension MITransactionEditorPresenter: AccountRequestor {
    func setAccount(_ account: Account) {
        interactor.setAccount(account, forTransactionItem: transactionItemForAccountSpecifyigId)
    }
}

extension MITransactionEditorPresenter: MITransactionEditorInteractorOutput {
    func fetched(transactionItems: [TransactionItem]) {
        var result: [TransactionItemViewModel] = []
        transactionItems.forEach({
            let path = $0.account?.path ?? NSLocalizedString("Account/Category",
                                                             tableName: Constants.Localizable.mITransactionEditorVC,
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
        view?.datePicker.date = date
    }

    func fetched(comment: String?) {
        view?.commentTextField.text = comment
    }

    private func configureAddTransactionItemButtons() {
        if transactionItems.filter({$0.type == .debit}).count > 1 {
            view?.creditAddButtonIsHidden = true
        } else {
            view?.creditAddButtonIsHidden = false
        }
        if transactionItems.filter({$0.type == .credit}).count > 1 {
            view?.debitAddButtonIsHidden = true
        } else {
            view?.debitAddButtonIsHidden = false
        }
    }
}
