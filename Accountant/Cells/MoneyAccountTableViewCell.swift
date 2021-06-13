//
//  MoneyAccountTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 19.05.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class MoneyAccountTableViewCell: UITableViewCell {
    @IBOutlet weak var accountIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var amountInBaseCurrency: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var creditLimitAmount: UILabel!
    
    let coreDataStack = CoreDataStack.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateCell(dataToShow: (account: Account, title: String, amountInAccountCurrency: Double, amountInAccountingCurrency: Double), accountingCurrency : Currency) {
        amountInBaseCurrency.text = ""
        creditLimitAmount.text = ""
        
        guard let currency = dataToShow.account.currency else {return}
        switch dataToShow.account.subType {
        case AccountSubType.cash.rawValue :
            accountIcon.image = UIImage(systemName: "bitcoinsign.circle")
        case AccountSubType.debitCard.rawValue:
            accountIcon.image = UIImage(systemName: "creditcard")
        case AccountSubType.creditCard.rawValue:
            accountIcon.image = UIImage(systemName: "creditcard.fill")
            if let credit = dataToShow.account.linkedAccount {
                let amount = round(AccountManager.balance(of: [credit])*100)/100
                if amount != 0 {
                    creditLimitAmount.text = "Credit limit: \(amount) \(credit.currency!.code!)"
                }
            }
        case AccountSubType.deposit.rawValue:
            accountIcon.image = UIImage(systemName: "hare")
        default:
            break
        }
        
        nameLabel.text = dataToShow.title
        
        
        if dataToShow.amountInAccountCurrency >= 0 {
            amountLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountLabel.textColor = .label
            self.accessoryType = .none
            if currency != accountingCurrency && dataToShow.amountInAccountingCurrency != 0 {
                amountInBaseCurrency.text = "≈\(dataToShow.amountInAccountingCurrency) \(accountingCurrency.code!)"
            }
        }
        else {
            amountLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountLabel.textColor = .systemRed
            self.accessoryType = .detailButton
        }
    }
    
    
    func updateCell(dataToShow: AccountData, accountingCurrency : Currency) {
        amountInBaseCurrency.text = " "
        creditLimitAmount.text = " "
        
        guard let account = dataToShow.account, let currency = account.currency else {return}
        
        switch account.subType {
        case AccountSubType.cash.rawValue:
            accountIcon.image = UIImage(systemName: "bitcoinsign.circle")
        case AccountSubType.debitCard.rawValue:
            accountIcon.image = UIImage(systemName: "creditcard")
        case AccountSubType.creditCard.rawValue:
            accountIcon.image = UIImage(systemName: "creditcard.fill")
            if let credit = dataToShow.account.linkedAccount {
                let amount = round(AccountManager.balance(of: [credit])*100)/100
                if amount != 0 {
                    creditLimitAmount.text = "Credit limit: \(amount) \(credit.currency!.code!)"
                }
            }
        case AccountSubType.deposit.rawValue:
            accountIcon.image = UIImage(systemName: "hare")
        default:
            break
        }
        
        nameLabel.text = dataToShow.title
        
        
        if dataToShow.amountInAccountCurrency >= 0 {
            amountLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountLabel.textColor = .label
            self.accessoryType = .none
            if currency != accountingCurrency {
                amountInBaseCurrency.text = "≈\(dataToShow.amountInAccountingCurrency) \(accountingCurrency.code!)"
            }
        }
        else {
            amountLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountLabel.textColor = .systemRed
            self.accessoryType = .detailButton
        }
    }
    
    
}
