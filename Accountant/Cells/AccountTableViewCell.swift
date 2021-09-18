//
//  AccountTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 18.09.2021.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    
    private var firstLaunch: Bool = true
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let iconStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let iconView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let indicatorView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let iconImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let amountStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let amountInAccountingCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let amountInAccountCurrencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
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
    
    private func setMainView(){
        guard firstLaunch else {return}
        firstLaunch = !firstLaunch
        
        //MARK:- Main View
        contentView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
        
        //MARK:- Icon Stack View
        mainView.addSubview(iconStackView)
        iconStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        iconStackView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        iconStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        iconStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 36).isActive = true
        
        //MARK:- Icon Image View
        iconStackView.addArrangedSubview(iconImageView)
        iconImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true
        
        //MARK:- Icon View
        iconStackView.addArrangedSubview(iconView)
        iconView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
        
        //MARK:- Indicator View
        iconView.addSubview(indicatorView)
        indicatorView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
        
        //MARK:- Name Label
        mainView.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: iconStackView.trailingAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        nameLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for:.horizontal)
       
        //MARK:- Amount Stack View
        mainView.addSubview(amountStackView)
        amountStackView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for:.horizontal)
        amountStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        amountStackView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        amountStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        amountStackView.heightAnchor.constraint(equalToConstant: 43).isActive = true
        amountStackView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8).isActive = true
        
        amountStackView.addArrangedSubview(amountInAccountingCurrencyLabel)
        amountStackView.addArrangedSubview(amountInAccountCurrencyLabel)
        amountStackView.addArrangedSubview(creditLimitInAccountCurrencyLabel)
    }
    
    
    func updateCellForData(_ dataToShow: AccountData, accountingCurrency : Currency) {
        setMainView()
        indicatorView.backgroundColor = dataToShow.color
        iconImageView.tintColor = dataToShow.color
        
        nameLabel.text = dataToShow.title
        amountInAccountingCurrencyLabel.text = " "
        creditLimitInAccountCurrencyLabel.text = " "
        
        guard let account = dataToShow.account, let currency = account.currency else {return}
        
        switch account.subType {
        case AccountSubType.cash.rawValue:
            if let myImage = UIImage(named: "wallet") {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                iconImageView.image = tintableImage
                iconImageView.isHidden = false
                iconView.isHidden = true
            }
        case AccountSubType.debitCard.rawValue:
            iconImageView.image = UIImage(systemName: "creditcard")
            iconImageView.isHidden = false
            iconView.isHidden = true
        case AccountSubType.creditCard.rawValue:
            iconImageView.image = UIImage(systemName: "creditcard.fill")
            iconImageView.isHidden = false
            iconView.isHidden = true
            if dataToShow.account.parent?.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money), let credit = dataToShow.account.linkedAccount {
                let amount = round(AccountManager.balance(of: [credit])*100)/100
                if amount != 0 {
                    creditLimitInAccountCurrencyLabel.text = "\(NSLocalizedString("Credit limit:",comment: "")) \(amount) \(credit.currency!.code!)"
                }
            }
        default:
            iconImageView.isHidden = true
            iconView.isHidden = false
        }
        
        
        if dataToShow.amountInAccountCurrency >= 0 {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountInAccountCurrencyLabel.textColor = .label
            self.accessoryType = .none
            if currency != accountingCurrency && dataToShow.amountInAccountingCurrency != 0 {
                if let accountingCurrencyCode = accountingCurrency.code {
                    amountInAccountingCurrencyLabel.text = "≈\(dataToShow.amountInAccountingCurrency) \(accountingCurrencyCode)"
                }
                else {
                    amountInAccountingCurrencyLabel.text = NSLocalizedString("Error", comment: "")
                }
            }
        }
        else {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountInAccountCurrencyLabel.textColor = .systemRed
            self.accessoryType = .detailButton
        }
    }
}
