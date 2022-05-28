//
//  MITransactionEditorViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import Foundation
import UIKit

protocol MITransactionEditorView: AnyObject {

    var creditAddButtonIsHidden: Bool { get set }
    var debitAddButtonIsHidden: Bool { get set }
    func configureView()
}

protocol TransactionItemDelegate: AnyObject {
    func accountRequestingForTransactionItem(id: UUID)
    func setAmount(forTrasactionItem id: UUID, amount: Double)
}

class MITransactionEditorViewController: UIViewController, AccountNavigationDelegate {

    var presenter: MITransactionEditorPresenterInput?

    private var activeTextField: UITextField?

    private let mainStackViewSpacing: CGFloat = 5
    private let mainView: UIView = {
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let debitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.systemBlue.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let creditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.systemBlue.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let debitTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let creditTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let debitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("To:",
                                       tableName: Constants.Localizable.mITransactionEditorVC,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let creditLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("From:",
                                       tableName: Constants.Localizable.mITransactionEditorVC,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let debitAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let creditAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let debitTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let creditTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 200
        textField.placeholder = NSLocalizedString("Comment",
                                                  tableName: Constants.Localizable.mITransactionEditorVC,
                                                  comment: "")
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let confirmButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.backgroundColor = Colors.Main.confirmButton
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if presenter?.isNewTransaction == true {
            self.navigationItem.title = NSLocalizedString("Add transaction",
                                                          tableName: Constants.Localizable.mITransactionEditorVC,
                                                          comment: "")
        } else {
            self.navigationItem.title = NSLocalizedString("Edit transaction",
                                                          tableName: Constants.Localizable.mITransactionEditorVC,
                                                          comment: "")
        }
        presenter?.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dismissKeyboard()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            presenter?.willMoveToParent()
        }
    }

    @objc private func changeDate(_ sender: UIDatePicker) {
        presenter?.setDate(sender.date)
    }

    @objc private func debitAddButtonDidClick() {
        presenter?.addDebitTransactionItem()
    }

    @objc private func creditAddButtonDidClick() {
        presenter?.addCreditTransactionItem()
    }

    @objc private func confirm() {
        presenter?.confirm()
    }
}

extension MITransactionEditorViewController: MITransactionEditorView {

    var creditAddButtonIsHidden: Bool {
        get {
            return creditAddButton.isHidden
        }
        set {
            creditAddButton.isHidden = newValue
        }
    }

    var debitAddButtonIsHidden: Bool {
        get {
            return debitAddButton.isHidden
        }
        set {
            debitAddButton.isHidden = newValue
        }
    }

    func configureView() {
        // Register cell for TableViews
        debitTableView.register(TransactionItemCell.self,
                                forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)
        creditTableView.register(TransactionItemCell.self,
                                 forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)

        // TableViews deledate
        debitTableView.delegate = self
        creditTableView.delegate = self

        // TableViews dataSource
        debitTableView.dataSource = self
        creditTableView.dataSource = self

        // TextField dataSource
        commentTextField.delegate = self

        // add GestureRecognizer to dismiss keyboard by touch on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        addTargets()
        addUIComponents()
    }

    private func addTargets() {
        datePicker.addTarget(self,
                             action: #selector(self.changeDate(_:)),
                             for: .valueChanged)
        debitAddButton.addTarget(self,
                                 action: #selector(self.debitAddButtonDidClick),
                                 for: .touchUpInside)
        creditAddButton.addTarget(self,
                                  action: #selector(self.creditAddButtonDidClick),
                                  for: .touchUpInside)
        confirmButton.addTarget(self,
                                action: #selector(self.confirm),
                                for: .touchUpInside)
    }

    private func addUIComponents() {

        view.backgroundColor = .systemBackground

        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 180).isActive = true

        mainView.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -40+8).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true

        mainView.addSubview(commentTextField)
        commentTextField.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20).isActive = true
        commentTextField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        commentTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true

        mainView.addSubview(mainStackView)
        mainStackView.spacing = mainStackViewSpacing
        mainStackView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -20).isActive = true

        mainStackView.addArrangedSubview(creditStackView)
        creditStackView.addArrangedSubview(creditTitleView)

        creditTitleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        creditTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        creditTitleView.addSubview(creditLabel)
        creditLabel.leadingAnchor.constraint(equalTo: creditTitleView.leadingAnchor, constant: 10).isActive = true
        creditLabel.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true

        creditTitleView.addSubview(creditAddButton)
        creditAddButton.trailingAnchor.constraint(equalTo: creditTitleView.trailingAnchor).isActive = true
        creditAddButton.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true
        creditAddButton.widthAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true
        creditAddButton.heightAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true

        creditStackView.addArrangedSubview(creditTableView)
        creditTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        creditTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5,
                                                constant: -30 - mainStackViewSpacing).isActive = true

        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitTitleView)

        debitTitleView.widthAnchor.constraint(equalToConstant: mainStackView.frame.width).isActive = true
        debitTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        debitTitleView.addSubview(debitLabel)
        debitLabel.leadingAnchor.constraint(equalTo: debitTitleView.leadingAnchor, constant: 10).isActive = true
        debitLabel.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true

        debitTitleView.addSubview(debitAddButton)
        debitAddButton.trailingAnchor.constraint(equalTo: debitTitleView.trailingAnchor).isActive = true
        debitAddButton.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true
        debitAddButton.widthAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true
        debitAddButton.heightAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true

        debitStackView.addArrangedSubview(debitTableView)
        debitTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        debitTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5,
                                               constant: -30 - mainStackViewSpacing).isActive = true
    }
}

extension MITransactionEditorViewController: TransactionItemDelegate {
    func accountRequestingForTransactionItem(id: UUID) {
        presenter?.accountRequestingForTransactionItem(id: id)
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double) {
        presenter?.setAmount(forTrasactionItem: id, amount: amount)
    }
}

extension MITransactionEditorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case debitTableView:
            return presenter?.debitTransactionItems.count ?? 0
        case creditTableView:
            return presenter?.creditTransactionItems.count ?? 0
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TransactionItemCell()
        guard let presenter = presenter else { return cell }
        switch tableView {
        case debitTableView:
            cell.configureCell(for: presenter.debitTransactionItems[indexPath.row], with: self)
        case creditTableView:
            cell.configureCell(for: presenter.creditTransactionItems[indexPath.row], with: self)
        default: break
        }
        return cell
    }
}

extension MITransactionEditorViewController: UITableViewDelegate {
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {// swiftlint:disable:this line_length
        guard let presenter = self.presenter else {return nil}
        switch tableView {
        case self.debitTableView:
            if !presenter.canBeDeleted(id: presenter.debitTransactionItems[indexPath.row].id) {
                return nil
            }
        case self.creditTableView:
            if !presenter.canBeDeleted(id: presenter.creditTransactionItems[indexPath.row].id) {
                return nil
            }
        default: return nil
        }

        let delete = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in
            switch tableView {
            case self.debitTableView:
                presenter.deleteTransactionItem(id: presenter.debitTransactionItems[indexPath.row].id)
            case self.creditTableView:
                presenter.deleteTransactionItem(id: presenter.creditTransactionItems[indexPath.row].id)
            default: return
            }
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Keyboard methods
extension MITransactionEditorViewController {
    @objc func keyboardWillShow(notification: Notification) {
        let saveDistance: CGFloat = 80
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, // swiftlint:disable:this line_length
           let activeTextField = activeTextField {
            let keyboardY = self.view.frame.size.height - keyboardSize.height - saveDistance
            var editingTextFieldY: CGFloat! = 0
            if  activeTextField.tag == 200 {  // comment
                editingTextFieldY = activeTextField.frame.origin.y
            }
            if editingTextFieldY > keyboardY - saveDistance {
                UIView.animate(withDuration: 0.25,
                               delay: 0.00,
                               options: UIView.AnimationOptions.curveEaseIn,
                               animations: {
                    self.view.frame = CGRect(x: 0,
                                             y: -(editingTextFieldY! - (keyboardY - saveDistance)),
                                             width: self.view.bounds.width,
                                             height: self.view.bounds.height)
                }, completion: nil)
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0.00, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 200, let comment = textField.text {
            presenter?.setComment(comment)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func doneButtonAction() {
        commentTextField.resignFirstResponder()
    }
}
