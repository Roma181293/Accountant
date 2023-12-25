//
//  AccountTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 18.09.2021.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    private var firstLaunch: Bool = true

    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let iconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let iconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let systemIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let customIconContainerView: UIView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let customIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let amountInCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let amountInAccountCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let creditLimitInAccountCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemPink
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private func setMainView() { // swiftlint:disable:this function_body_length
        guard firstLaunch else {return}
        firstLaunch = !firstLaunch
        // Main View
        contentView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                             constant: -2).isActive = true
        // Icon Stack View
        mainView.addSubview(iconStackView)
        iconStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        iconStackView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        iconStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        iconStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 36).isActive = true
        // System Icon Image View
        iconStackView.addArrangedSubview(systemIconImageView)
        systemIconImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        systemIconImageView.heightAnchor.constraint(equalTo: systemIconImageView.widthAnchor).isActive = true
        // Custom Icon Container View
        iconStackView.addArrangedSubview(customIconContainerView)
        customIconContainerView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        customIconContainerView.heightAnchor.constraint(equalTo: customIconContainerView.widthAnchor).isActive = true
        // Custom Icon Image View
        customIconContainerView.addSubview(customIconImageView)
        customIconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        customIconImageView.heightAnchor.constraint(equalTo: customIconImageView.widthAnchor).isActive = true
        customIconImageView.centerYAnchor.constraint(equalTo: customIconContainerView.centerYAnchor).isActive = true
        customIconImageView.centerXAnchor.constraint(equalTo: customIconContainerView.centerXAnchor).isActive = true
        // Icon View
        iconStackView.addArrangedSubview(iconView)
        iconView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
        // Indicator View
        iconView.addSubview(indicatorView)
        indicatorView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
        // Name Label
        mainView.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: iconStackView.trailingAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        nameLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        // Amount Stack View
        mainView.addSubview(amountStackView)
        amountStackView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        amountStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        amountStackView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        amountStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        amountStackView.heightAnchor.constraint(equalToConstant: 43).isActive = true
        amountStackView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8).isActive = true

        amountStackView.addArrangedSubview(amountInCurrencyLabel)
        amountStackView.addArrangedSubview(amountInAccountCurrencyLabel)
        amountStackView.addArrangedSubview(creditLimitInAccountCurrencyLabel)
    }

    func updateCellForData(_ dataToShow: AccountData, currency: Currency) { // swiftlint:disable:this function_body_length line_length
        setMainView()
        indicatorView.backgroundColor = dataToShow.color
        systemIconImageView.tintColor = dataToShow.color
        customIconImageView.tintColor = dataToShow.color

        nameLabel.text = dataToShow.title
        amountInCurrencyLabel.text = " "
        creditLimitInAccountCurrencyLabel.text = " "

        guard let account = dataToShow.account, let accountCurrency = account.currency else {return}

        switch account.type.name {
        case AccountType.NameEnum.cash.rawValue:
            systemIconImageView.image = UIImage(systemName: "banknote")
            systemIconImageView.isHidden = false
            customIconContainerView.isHidden = true
            iconView.isHidden = true
        case AccountType.NameEnum.debitCard.rawValue:
            systemIconImageView.image = UIImage(systemName: "creditcard")
            systemIconImageView.isHidden = false
            customIconContainerView.isHidden = true
            iconView.isHidden = true
        case AccountType.NameEnum.creditCard.rawValue:
            systemIconImageView.image = UIImage(systemName: "creditcard.fill")
            systemIconImageView.isHidden = false
            customIconContainerView.isHidden = true
            iconView.isHidden = true
            if dataToShow.account.parent?.name == LocalizationManager.getLocalizedName(.money),
               let credit = dataToShow.account.linkedAccount {
                let amount = round(credit.balance*100)/100
                if amount >= 0 {
                    creditLimitInAccountCurrencyLabel.text = "\(NSLocalizedString("Credit limit:", comment: "")) \(amount) \(credit.currency!.code)" // swiftlint:disable:this line_length
                }
            }
        default:
            systemIconImageView.isHidden = true
            customIconContainerView.isHidden = true
            iconView.isHidden = false
        }

        if dataToShow.amountInAccountCurrency >= 0 {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(accountCurrency.code)"
            amountInAccountCurrencyLabel.textColor = Colors.Main.defaultCellTextColor
            self.accessoryType = .none
            if accountCurrency != currency && dataToShow.amountInSelectedCurrency != 0 {
                amountInCurrencyLabel.text = "≈\(dataToShow.amountInSelectedCurrency) \(currency.code)"
            }
        } else {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(accountCurrency.code)"
            amountInAccountCurrencyLabel.textColor = .systemRed
            self.accessoryType = .detailButton
        }
    }
}
