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

    private var nameIdEdited: Bool = false

    override func loadView() {
        view = mainView
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // set delegates
        mainView.nameTextField.delegate = self
        mainView.balanceTextField.delegate = self
        mainView.linkedAccountBalanceTextField.delegate = self
        mainView.exchangeRateTextField.delegate = self
        mainView.mainScrollView.delegate = self

        mainView.confirmButton.addTarget(self, action: #selector(confirmButtonDidTouch), for: .touchUpInside)
        mainView.currencyButton.addTarget(self, action: #selector(currencyButtonDidTouch), for: .touchUpInside)
        mainView.keeperButton.addTarget(self, action: #selector(keeperButtonDidTouch), for: .touchUpInside)
        mainView.holderButton.addTarget(self, action: #selector(holderButtonDidTouch), for: .touchUpInside)
        mainView.typeButton.addTarget(self, action: #selector(typeButtonDidTouch), for: .touchUpInside)
        mainView.nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged(_:)), for: .editingChanged)
        mainView.balanceTextField.addTarget(self, action: #selector(balanceTextFieldEditingChanged(_:)), for: .editingChanged)
        mainView.linkedAccountBalanceTextField.addTarget(self, action: #selector(creditLimitTextFieldEditingChanged(_:)), for: .editingChanged)
        mainView.exchangeRateTextField.addTarget(self, action: #selector(exchangeRateTextFieldEditingChanged(_:)), for: .editingChanged)
        mainView.datePicker.addTarget(self, action: #selector(balanceDateDidChanged(_:)), for: .valueChanged)
        
        addDoneButtonOnDecimalKeyboard()
        output?.viewDidLoad()
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
        nameIdEdited = true
        output?.nameChangedTo(sender.text ?? "")
    }

    @objc func balanceTextFieldEditingChanged(_ sender: UITextField) {
        output?.setBalance(sender.text ?? "")
    }

    @objc func creditLimitTextFieldEditingChanged(_ sender: UITextField) {
        output?.setLinkedAccountBalance(sender.text ?? "")
    }

    @objc func exchangeRateTextFieldEditingChanged(_ sender: UITextField) {
        output?.setExhangeRate(sender.text ?? "")
    }

    @objc func balanceDateDidChanged(_ sender: UIDatePicker) {
        output?.balanceDateDidChanged(sender.date)
    }
}

extension AccountEditorViewController: AccountEditorViewInput {
    func configureView() {

    }

    func colorNameTextFieldForState(_ isValid: Bool) {
        if nameIdEdited && !isValid {
            mainView.nameTextField.backgroundColor = .systemPink.withAlphaComponent(0.2)
        } else {
            mainView.nameTextField.backgroundColor = .systemBackground
        }
    }

    func nameDidSet(_ name: String) {
        mainView.nameTextField.text = name
    }

    func typeDidSet(_ accountType: AccountTypeViewModel?, isSingle: Bool, mode: AccountEditorWorker.Mode) {
        guard let accountType = accountType else {
            mainView.typeButton.setTitle("", for: .normal)
            return
        }

        mainView.typeButton.setTitle(accountType.name, for: .normal)
        mainView.typeButton.isHidden = isSingle
        mainView.typeLabel.isHidden = isSingle

        mainView.keeperLabel.isHidden = !accountType.hasKeeper
        mainView.keeperButton.isHidden = !accountType.hasKeeper

        mainView.holderLabel.isHidden = !accountType.hasHolder
        mainView.holderButton.isHidden = !accountType.hasHolder

        mainView.currencyLabel.isHidden = !accountType.hasCurrency
        mainView.currencyButton.isHidden = !accountType.hasCurrency

        let keeperIsHidden = accountType.keeperType == .cash || accountType.keeperType == .none
        mainView.keeperLabel.isHidden = keeperIsHidden
        mainView.keeperButton.isHidden = keeperIsHidden

        if mode == .create {
            mainView.balanceOnDateLabel.isHidden = !accountType.hasInitialBalance
            mainView.datePicker.isHidden = !accountType.hasInitialBalance
            mainView.balanceTextField.isHidden = !accountType.hasInitialBalance

            if let linkedAccountType = accountType.linkedAccountType {
                mainView.linkedAccountBalanceLabel.isHidden = !linkedAccountType.hasInitialBalance
                mainView.linkedAccountBalanceTextField.isHidden = !linkedAccountType.hasInitialBalance
            } else {
                mainView.linkedAccountBalanceLabel.isHidden = true
                mainView.linkedAccountBalanceTextField.isHidden = true
            }
        } else {
            mainView.balanceOnDateLabel.isHidden = true
            mainView.datePicker.isHidden = true
            mainView.balanceTextField.isHidden = true
            mainView.linkedAccountBalanceLabel.isHidden = true
            mainView.linkedAccountBalanceTextField.isHidden = true
            mainView.typeButton.isUserInteractionEnabled = false
        }
    }

    func currencyDidSet(_ currency: CurrencyViewModel?, accountingCurrency: CurrencyViewModel) {
        if let currency = currency {
            mainView.currencyButton.setTitle(currency.code, for: .normal)
            mainView.exchangeRateTextField.isHidden = (currency.id == accountingCurrency.id)
            mainView.exchangeRateLabel.isHidden = (currency.id == accountingCurrency.id)
            let placeholder = String(format: NSLocalizedString("How many %@ you have to pay for 1 %@",
                                                               tableName: Constants.Localizable.accountEditor,
                                                               comment: ""),
                                     accountingCurrency.code, currency.code)
            mainView.exchangeRateTextField.placeholder = placeholder
            mainView.exchangeRateLabel.text = accountingCurrency.code + "/" + currency.code
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

    func rateDidSet(_ rate: Double?) {
        if let rate = rate {
            mainView.exchangeRateLabel.text = String(rate)
        } else {
            mainView.exchangeRateLabel.text = ""
        }
    }

    func setTitle(_ title: String) {
        self.navigationItem.title = title
    }

    func configureComponentsForEditMode() {
        mainView.currencyButton.isUserInteractionEnabled = false
        mainView.datePicker.isHidden = true
        mainView.balanceOnDateLabel.isHidden = true
        mainView.balanceTextField.isHidden = true
        mainView.linkedAccountBalanceTextField.isHidden = true
        mainView.linkedAccountBalanceLabel.isHidden = true
        mainView.exchangeRateLabel.isHidden = true
        mainView.exchangeRateTextField.isHidden = true
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
        mainView.linkedAccountBalanceTextField.resignFirstResponder()
        mainView.exchangeRateTextField.resignFirstResponder()
    }
    
    private func addDoneButtonOnDecimalKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let title = NSLocalizedString("Done",
                                      tableName: Constants.Localizable.mITransactionEditor,
                                      comment: "")
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self,
                                                    action: #selector(self.doneButtonAction))
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0,
                                                                  width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        mainView.nameTextField.inputAccessoryView = doneToolbar
        mainView.balanceTextField.inputAccessoryView = doneToolbar
        mainView.linkedAccountBalanceTextField.inputAccessoryView = doneToolbar
        mainView.exchangeRateTextField.inputAccessoryView = doneToolbar
    }
}
