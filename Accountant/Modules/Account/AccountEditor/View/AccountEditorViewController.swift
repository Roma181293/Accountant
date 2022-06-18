//
//  AccountEditorViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import UIKit

class AccountEditorViewController: UIViewController {

    // MARK: - Properties
    var output: AccountEditorViewOutput?

    private var mainView = AccountEditorView()

    override func loadView() {
        view = mainView
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // set delegates
        mainView.nameTextField.delegate = self
        mainView.balanceTextField.delegate = self
        mainView.creditLimitTextField.delegate = self
        mainView.exchangeRateTextField.delegate = self
        mainView.mainScrollView.delegate = self

        mainView.confirmButton.addTarget(self, action: #selector(confirmButtonDidTouch), for: .touchUpInside)
        mainView.currencyButton.addTarget(self, action: #selector(currencyButtonDidTouch), for: .touchUpInside)
        mainView.keeperButton.addTarget(self, action: #selector(keeperButtonDidTouch), for: .touchUpInside)
        mainView.holderButton.addTarget(self, action: #selector(holderButtonDidTouch), for: .touchUpInside)
        mainView.typeButton.addTarget(self, action: #selector(typeButtonDidTouch), for: .touchUpInside)
        mainView.nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged(_:)), for: .editingChanged)
    }

    @objc func confirmButtonDidTouch() {
        output?.confirmButtonDidTouch()
    }

    @objc func currencyButtonDidTouch() {
        output?.currencyButtonDidTouch()
    }

    @objc func keeperButtonDidTouch() {
        output?.keeperButtonDidTouch()
    }

    @objc func holderButtonDidTouch() {
        output?.holderButtonDidTouch()
    }

    @objc func typeButtonDidTouch() {
        output?.typeButtonDidTouch()
    }

    @objc func nameTextFieldEditingChanged(_ sender: UITextField) {
        output?.nameChangedTo(sender.text ?? "")
    }

    func balanceTextFieldEditingChanged(_ sender: UITextField) {
        output?.balanceChangedTo(sender.text ?? "")
    }
    func creditLimitTextFieldEditingChanged(_ sender: UITextField) {
        output?.creditLimitChangedTo(sender.text ?? "")
    }
    func exchangeRateTextFieldEditingChanged(_ sender: UITextField) {
        output?.exchangeRateChangedTo(sender.text ?? "")
    }
}

extension AccountEditorViewController: AccountEditorViewInput {
    func configureView() {

    }

    func colorNameTextField(_ color: UIColor) {
        mainView.nameTextField.backgroundColor = color
    }

    func typeDidSet(_ accountType: AccountTypeViewModel?) {
        if let accountType = accountType {
            mainView.typeButton.setTitle(accountType.name, for: .normal)
        } else {
            mainView.typeButton.setTitle("", for: .normal)
        }
    }

    func currencyDidSet(_ currency: CurrencyViewModel?) {
        if let currency = currency {
            mainView.currencyButton.setTitle(currency.code, for: .normal)
        } else {
            mainView.currencyButton.setTitle("", for: .normal)
        }
    }

    func holderDidSet(_ holder: HolderViewModel?) {
        if let holder = holder {
            mainView.holderButton.setTitle(holder.icon + " - " + holder.name, for: .normal)
        } else {
            mainView.holderButton.setTitle("", for: .normal)
        }
    }

    func keeperDidSet(_ keeper: KeeperViewModel?) {
        if let keeper = keeper {
            mainView.keeperButton.setTitle(keeper.name, for: .normal)
        } else {
            mainView.keeperButton.setTitle("", for: .normal)
        }
    }
}

// MARK: - Keyboard methods
extension AccountEditorViewController: UIScrollViewDelegate {
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 40), right: 0.0)
        mainView.mainScrollView.contentInset = contentInsets
        mainView.mainScrollView.scrollIndicatorInsets = contentInsets
        mainView.mainScrollView.contentSize = self.view.frame.size
    }

    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        mainView.mainScrollView.contentInset = contentInsets
        mainView.mainScrollView.scrollIndicatorInsets = contentInsets
        mainView.mainScrollView.contentSize = self.mainView.frame.size
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func doneButtonAction() {
        mainView.nameTextField.resignFirstResponder()
        mainView.balanceTextField.resignFirstResponder()
        mainView.creditLimitTextField.resignFirstResponder()
        mainView.exchangeRateTextField.resignFirstResponder()
    }
}
