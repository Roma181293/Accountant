//
//  TransactionCell.swift
//  Accountant
//
//  Created by Roman Topchii on 29.08.2021.
//

import UIKit

class TransactionCell: UITableViewCell { // swiftlint:disable:this type_body_length

    private unowned var transaction: Transaction!

    private var itemViewArray: [UIView] = []
    private var firstLaunch: Bool = true
    private var cellMainColor: UIColor = .systemGray

    private let labelsAlpha: CGFloat = 0.15
    private let backGroundAlpha: CGFloat = 0.2

    private let mainView: UIView = {
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "blackGrayColor")
        label.alpha = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let debitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let creditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let commentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let debitItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let creditItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let debitLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + NSLocalizedString("To:", tableName: Constants.Localizable.transactionListVC, comment: "")
        label.textColor = UIColor(named: "blackGrayColor")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let creditLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + NSLocalizedString("From:", tableName: Constants.Localizable.transactionListVC, comment: "")
        label.textColor = UIColor(named: "blackGrayColor")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + NSLocalizedString("Comment:", tableName: Constants.Localizable.transactionListVC, comment: "") + "  "
        label.textColor = UIColor(named: "blackGrayColor")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "blackGrayColor")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        debitLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        creditLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        commentLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
    }

    private func setMainView() {
        guard firstLaunch else {return}
        firstLaunch = !firstLaunch

        // Main View
        contentView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                             constant: -4).isActive = true
        // Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 6).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -6).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -8).isActive = true
        // Date Label
        mainStackView.addArrangedSubview(dateLabel)
        dateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let labelWidth = CGFloat(max(creditLabel.text!.count, debitLabel.text!.count)) * 7.5
        // Credit content
        mainStackView.addArrangedSubview(creditStackView)
        creditStackView.addArrangedSubview(creditLabel)
        creditLabel.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        creditLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        creditStackView.addArrangedSubview(creditItemsStackView)
        // Debit content
        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitLabel)
        debitLabel.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        debitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        debitStackView.addArrangedSubview(debitItemsStackView)
        // Comment
        mainStackView.addArrangedSubview(commentStackView)
        commentStackView.addArrangedSubview(commentLabel)
        commentLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        commentLabel.window?.canResizeToFitContent = true
        commentStackView.addArrangedSubview(commentContentLabel)
    }

    func setTransaction(_ transaction: Transaction) { // swiftlint:disable:this function_body_length cyclomatic_complexity line_length
        self.transaction = transaction

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")") // swiftlint:disable:this line_length

        dateLabel.text = formatter.string(from: transaction.date)

        if let comment = transaction.comment, !comment.isEmpty {
            commentStackView.isHidden = false
            commentContentLabel.text = comment
        } else {
            commentStackView.isHidden = true
        }

        itemViewArray.forEach({$0.removeFromSuperview()})

        for item in transaction.itemsList.sorted(by: {$0.amount >= $1.amount}) {

            let itemView = UIView()
            itemView.translatesAutoresizingMaskIntoConstraints = false

            let accountPathLabel = UILabel()
            if let acctount = item.account {
                accountPathLabel.text = acctount.path
            }
            accountPathLabel.textColor = UIColor(named: "blackGrayColor")
            accountPathLabel.numberOfLines = 0
            accountPathLabel.lineBreakMode = .byWordWrapping
            accountPathLabel.translatesAutoresizingMaskIntoConstraints = false

            let amountAndCurrencyLabel = UILabel()
            if let acctount = item.account, let currency = acctount.currency {
                amountAndCurrencyLabel.text = cutNumber(item.amount) + currency.code
            } else {
                amountAndCurrencyLabel.text = "Invalid data"
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

        setMainView()

        if transaction.itemsList.count >= 2 && transaction.applied == true {
            guard transaction.itemsList.filter({$0.type == .debit})[0].account != nil &&
                    transaction.itemsList.filter({$0.type == .credit})[0].account != nil else {return}
            let debitRootName = transaction.itemsList.filter({$0.type == .debit})[0].account!.rootAccount.name
            let creditRootName = transaction.itemsList.filter({$0.type == .credit})[0].account!.rootAccount.name

            if creditRootName == LocalisationManager.getLocalizedName(.income) &&
                debitRootName == LocalisationManager.getLocalizedName(.money) {
                cellMainColor = .systemGreen
            } else  if (creditRootName == LocalisationManager.getLocalizedName(.money) ||
                      creditRootName == LocalisationManager.getLocalizedName(.credits)) &&
                        debitRootName == LocalisationManager.getLocalizedName(.expense) {
                cellMainColor = .systemPink
            } else  if creditRootName == LocalisationManager.getLocalizedName(.money) &&
                        debitRootName == LocalisationManager.getLocalizedName(.money) {
                cellMainColor = .systemTeal
            } else {
                cellMainColor = .systemGray
            }
        } else {
            cellMainColor = .purple
        }

        debitLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        creditLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        commentLabel.layer.backgroundColor = cellMainColor.cgColor.copy(alpha: labelsAlpha)
        mainView.backgroundColor = UIColor(cgColor: cellMainColor.cgColor.copy(alpha: backGroundAlpha)!)
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
