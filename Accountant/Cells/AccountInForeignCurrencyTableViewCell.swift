//
//  AccountInForeignCurrencyTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 08.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class AccountInForeignCurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountInBaseCurrencyLabel: UILabel!
    @IBOutlet weak var amountInAccountCurrencyLabel: UILabel!
    @IBOutlet weak var spaceLabel: UILabel!
    
    
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
        amountInBaseCurrencyLabel.text = " "
        spaceLabel.text = " "
        
        guard let currency = dataToShow.account.currency else {return}
        
        nameLabel.text = dataToShow.title
        
        if dataToShow.amountInAccountCurrency >= 0 {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountInAccountCurrencyLabel.textColor = .label
            self.accessoryType = .none
            if currency != accountingCurrency {
                amountInBaseCurrencyLabel.text = "≈\(round(dataToShow.amountInAccountingCurrency * 100) / 100) \(accountingCurrency.code!)"
            }
        }
        else {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountInAccountCurrencyLabel.textColor = .systemRed
            self.accessoryType = .detailButton
        }
    }
    
    
    func updateCell(dataToShow: AccountData, accountingCurrency : Currency) {
        amountInBaseCurrencyLabel.text = " "
        spaceLabel.text = " "
        guard let account = dataToShow.account, let currency = account.currency else {return}
        
        nameLabel.text = dataToShow.title
        
        if dataToShow.amountInAccountCurrency >= 0 {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountInAccountCurrencyLabel.textColor = .label
            self.accessoryType = .none
            if currency != accountingCurrency && dataToShow.amountInAccountingCurrency != 0 {
                amountInBaseCurrencyLabel.text = "≈\(round(dataToShow.amountInAccountingCurrency * 100) / 100) \(accountingCurrency.code!)"
            }
        }
        else {
            amountInAccountCurrencyLabel.text = "\(dataToShow.amountInAccountCurrency) \(currency.code!)"
            amountInAccountCurrencyLabel.textColor = .systemRed
            self.accessoryType = .detailButton
        }
    }
}
