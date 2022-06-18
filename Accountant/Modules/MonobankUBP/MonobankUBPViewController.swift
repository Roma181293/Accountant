//
//  MonobankUBPViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit
import SafariServices

protocol MonobankUBPView: AnyObject {
    func configureView()
    func setConfirmButtonIsHidden(_ isHidden: Bool)
    func setHolderComponentIsHidden(_ isHidden: Bool)
    func setHolderButtonTitle(with title: String)
    func tableViewReloadData()
    func setGetDataButtonIsUserInteractionEnabled(_ isUserInteractionEnabled: Bool)
}

class MonobankUBPViewController: UIViewController {

    var presenter: MonobankUBPPresenterProtocol!
    let configurator: MonobankUBPConfiguratorProtocol = MonobankUBPConfigurator()

    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let consolidatedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("To automatically adding your transactions from the Monobank accounts please " +
                                       "enter Token in the field below",
                                       tableName: Constants.Localizable.monobankVC,
                                       comment: "")
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let getTokenLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("Get token", tableName: Constants.Localizable.monobankVC, comment: "")
        titleLabel.textColor = .systemBlue
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    let apiDocLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("API documentation",
                                            tableName: Constants.Localizable.monobankVC,
                                            comment: "")
        titleLabel.textColor = .systemBlue
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    let leadingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let trailingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let tokenLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Token", tableName: Constants.Localizable.monobankVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tokenTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 1000
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

    let getDataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let holderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Holder", tableName: Constants.Localizable.monobankVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let holderButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let getDataButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("Get data",
                                          tableName: Constants.Localizable.monobankVC,
                                          comment: ""),
                        for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let bankAccountsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("Add accounts",
                                          tableName: Constants.Localizable.monobankVC,
                                          comment: ""), for:
                                .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        presenter.configureView()
    }

    @objc func aboutApiLabelClicked(_ sender: UITapGestureRecognizer? = nil) {
        presenter.openAboutApi()
    }

    @objc func getTokenLabelClicked(_ sender: UITapGestureRecognizer? = nil) {
        presenter.openGetToken()
    }

    @objc func getDataButtonClicked() {
        presenter.getDataButtonClicked(with: tokenTextField.text ?? "")
    }

    @objc func holderButtonClicked() {
        presenter.holderButtonClicked()
    }

    @objc func confirmButtonClicked() {
        presenter.confirmButtonClicked()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension MonobankUBPViewController: MonobankUBPView {
    func configureView() { // swiftlint:disable:this function_body_length
        bankAccountsTableView.dataSource = self
        bankAccountsTableView.register(MonobankAccountCell.self,
                                             forCellReuseIdentifier: Constants.Cell.bankAccountCell)

        self.navigationItem.title = NSLocalizedString("Monobank",
                                                            tableName: Constants.Localizable.monobankVC,
                                                            comment: "")

        getDataButton.addTarget(self, action: #selector(self.getDataButtonClicked), for: .touchUpInside)
        holderButton.addTarget(self, action: #selector(self.holderButtonClicked), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirmButtonClicked), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
               view.addGestureRecognizer(tap)

        let getTokenLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.getTokenLabelClicked))
        getTokenLabel.isUserInteractionEnabled = true
        getTokenLabel.addGestureRecognizer(getTokenLabelTap)

        let aboutApiDocLableTap = UITapGestureRecognizer(target: self, action: #selector(self.aboutApiLabelClicked))
        apiDocLabel.isUserInteractionEnabled = true
        apiDocLabel.addGestureRecognizer(aboutApiDocLableTap)

        holderButton.isHidden = true
        holderLabel.isHidden = true
        confirmButton.isHidden = true

        view.backgroundColor = .systemBackground
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                           constant: -10).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true

        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true

        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(getTokenLabel)
        mainStackView.addArrangedSubview(apiDocLabel)
        mainStackView.setCustomSpacing(20, after: apiDocLabel)

        mainStackView.addArrangedSubview(consolidatedStackView)
        consolidatedStackView.addArrangedSubview(leadingStackView)
        consolidatedStackView.addArrangedSubview(trailingStackView)

        leadingStackView.addArrangedSubview(tokenLabel)
        tokenLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        tokenLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true

        leadingStackView.addArrangedSubview(getDataView)
        getDataView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        getDataView.widthAnchor.constraint(equalToConstant: 80).isActive = true

        leadingStackView.addArrangedSubview(holderLabel)
        holderLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true

        trailingStackView.addArrangedSubview(tokenTextField)
        tokenTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true

        trailingStackView.addArrangedSubview(getDataButton)
        getDataButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        getDataButton.widthAnchor.constraint(equalToConstant: 80).isActive = true

        trailingStackView.addArrangedSubview(holderButton)
        holderButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderButton.widthAnchor.constraint(equalToConstant: 80).isActive = true

        mainView.addSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true

        mainView.addSubview(bankAccountsTableView)
        bankAccountsTableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        bankAccountsTableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        bankAccountsTableView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20).isActive = true
        bankAccountsTableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20).isActive = true
    }

    func setConfirmButtonIsHidden(_ isHidden: Bool) {
        confirmButton.isHidden = isHidden
    }

    func setHolderComponentIsHidden(_ isHidden: Bool) {
        holderButton.isHidden = isHidden
        holderLabel.isHidden = isHidden
    }

    func setHolderButtonTitle(with title: String) {
        holderButton.setTitle(title, for: .normal)
    }

    func tableViewReloadData() {
        bankAccountsTableView.reloadData()
    }

    func setGetDataButtonIsUserInteractionEnabled(_ isUserInteractionEnabled: Bool) {
        getDataButton.isUserInteractionEnabled = isUserInteractionEnabled
    }

}
extension MonobankUBPViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfBankAccounts()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.bankAccountCell,
                                                 for: indexPath) as! MonobankAccountCell // swiftlint:disable:this force_cast
        cell.configureCell(presenter.accountInfoAt(indexPath.row))
        return cell
    }
}
