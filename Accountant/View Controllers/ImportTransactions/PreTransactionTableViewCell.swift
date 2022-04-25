//
//  PreTransactionTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 23.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class PreTransactionTableViewCell: UITableViewCell {

    private unowned var transaction: Transaction!
    private var itemViewArray: [UIView] = []
    private var firstLaunch: Bool = true
    private var cellMainColor: UIColor = .systemGray
    private let labelsAlpha: CGFloat = 0.15
    private let backGroundAlpha: CGFloat = 0.2

    let mainView: UIView = {
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "blackGrayColor")
        label.alpha = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let debitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let creditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let debitItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let creditItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let debitLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + NSLocalizedString("To:", comment: "")
        label.textColor = UIColor(named: "blackGrayColor")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let creditLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + NSLocalizedString("From:", comment: "")
        label.textColor = UIColor(named: "blackGrayColor")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        debitLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        creditLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
    }

    private func setMainView() {
        guard firstLaunch else {return}
        firstLaunch = !firstLaunch
        // MARK: - Main View
        contentView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                             constant: -4).isActive = true
        // MARK: - Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 6).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -6).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -8).isActive = true
        // MARK: - Date Label
        mainStackView.addArrangedSubview(dateLabel)
        dateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let labelWidth = CGFloat(max(creditLabel.text!.count, debitLabel.text!.count)) * 7.5
        // MARK: - Credit content
        mainStackView.addArrangedSubview(creditStackView)
        creditStackView.addArrangedSubview(creditLabel)
        creditLabel.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        creditLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        creditStackView.addArrangedSubview(creditItemsStackView)
        // MARK: - Debit content
        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitLabel)
        debitLabel.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        debitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        debitStackView.addArrangedSubview(debitItemsStackView)
    }

    func setTransaction(_ transaction: Transaction) {
        self.transaction = transaction
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")

        dateLabel.text = formatter.string(from: transaction.date)
        dateLabel.layer.backgroundColor = UIColor.clear.cgColor
        dateLabel.textColor = UIColor(named: "blackGrayColor")
        dateLabel.layer.cornerRadius = 8

        itemViewArray.forEach({$0.removeFromSuperview()})

        for item in transaction.itemsList {
            configureTransactionItem(item)
        }
        setMainView()

        guard let debitAccount = transaction.itemsList.filter({$0.type == .debit}).first?.account,
              let creditAccount = transaction.itemsList.filter({$0.type == .credit}).first?.account
        else {return}

        let debitRootName = debitAccount.rootAccount.name
        let creditRootName = creditAccount.rootAccount.name

        if creditRootName == LocalisationManager.getLocalizedName(.income) &&
            debitRootName == LocalisationManager.getLocalizedName(.money) {
            cellMainColor = .systemGreen
        } else if (creditRootName == LocalisationManager.getLocalizedName(.money) ||
                    creditRootName == LocalisationManager.getLocalizedName(.credits)) &&
                    debitRootName == LocalisationManager.getLocalizedName(.expense) {
            cellMainColor = .systemPink
        } else if creditRootName == LocalisationManager.getLocalizedName(.money) &&
                    debitRootName == LocalisationManager.getLocalizedName(.money) {
            cellMainColor = .systemTeal
        } else {
            cellMainColor = .systemGray
        }
        debitLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        creditLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        mainView.backgroundColor = UIColor(cgColor: cellMainColor.cgColor.copy(alpha: backGroundAlpha)!)
    }

    private func configureTransactionItem(_ item: TransactionItem) {
        let itemView = UIView()
        itemView.translatesAutoresizingMaskIntoConstraints = false

        let accountPathLabel = UILabel()
        if let account = item.account {
            accountPathLabel.text = account.path
        } else {
            accountPathLabel.text = "Error"
            accountPathLabel.layer.backgroundColor = UIColor.red.cgColor
            accountPathLabel.textColor = UIColor(named: "blackGrayColor")
            accountPathLabel.textAlignment = .left
            accountPathLabel.layer.cornerRadius = 8
        }
        accountPathLabel.textColor = UIColor(named: "blackGrayColor")
        accountPathLabel.numberOfLines = 0
        accountPathLabel.lineBreakMode = .byWordWrapping
        accountPathLabel.translatesAutoresizingMaskIntoConstraints = false

        let amountAndCurrencyLabel = UILabel()
        if let account = item.account, let currency = account.currency {
            if item.amount < 0 {
                amountAndCurrencyLabel.text = "Error " + currency.code
                amountAndCurrencyLabel.layer.backgroundColor = UIColor.red.cgColor
                amountAndCurrencyLabel.textColor = UIColor(named: "blackGrayColor")
                amountAndCurrencyLabel.textAlignment = .right
                amountAndCurrencyLabel.layer.cornerRadius = 8
            } else {
                amountAndCurrencyLabel.text = cutNumber(item.amount) + currency.code
            }
        } else {
            if item.amount < 0 {
                amountAndCurrencyLabel.text = "Error " + "Error"
                amountAndCurrencyLabel.layer.backgroundColor = UIColor.red.cgColor
                amountAndCurrencyLabel.textColor = UIColor(named: "blackGrayColor")
                amountAndCurrencyLabel.textAlignment = .right
                amountAndCurrencyLabel.layer.cornerRadius = 8
            } else {
                amountAndCurrencyLabel.text = cutNumber(item.amount) + "Error"
                amountAndCurrencyLabel.layer.backgroundColor = UIColor.red.cgColor
                amountAndCurrencyLabel.textColor = UIColor(named: "blackGrayColor")
                amountAndCurrencyLabel.textAlignment = .right
                amountAndCurrencyLabel.layer.cornerRadius = 8
            }
        }
        amountAndCurrencyLabel.textColor = UIColor(named: "blackGrayColor")
        amountAndCurrencyLabel.textAlignment = .right
        amountAndCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false

        itemView.addSubview(accountPathLabel)
        accountPathLabel.leadingAnchor.constraint(equalTo: itemView.leadingAnchor).isActive = true
        accountPathLabel.topAnchor.constraint(equalTo: itemView.topAnchor).isActive = true
        accountPathLabel.bottomAnchor.constraint(equalTo: itemView.bottomAnchor).isActive = true

        itemView.addSubview(amountAndCurrencyLabel)
        amountAndCurrencyLabel.leadingAnchor.constraint(equalTo: accountPathLabel.trailingAnchor,
                                                        constant: 8).isActive = true
        amountAndCurrencyLabel.trailingAnchor.constraint(equalTo: itemView.trailingAnchor).isActive = true
        amountAndCurrencyLabel.topAnchor.constraint(equalTo: itemView.topAnchor).isActive = true

        accountPathLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        amountAndCurrencyLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)

        if item.type == .debit {
            debitItemsStackView.addArrangedSubview(itemView)
        } else if item.type == .credit {
            creditItemsStackView.addArrangedSubview(itemView)
        }
        itemViewArray.append(itemView)
    }

    private func cutNumber(_ number: Double) -> String {
        var amount: String
        if abs(number) >= 1_000_000_000 {
            amount = "\(round(number / 100_000_000)/10)B "
        } else if abs(number) >= 1_000_000 && abs(number) < 1_000_000_000 {
            amount = "\(round(number / 100_000)/10)M "
        } else if abs(number) >= 100_000 && abs(number) < 1_000_000 {
            amount = "\(round(number / 100)/10)K "
        } else {
            amount = "\(Int(number)) "
        }
        return amount
    }
}
