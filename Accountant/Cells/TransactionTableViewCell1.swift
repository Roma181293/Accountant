//
//  TransactionTableViewCell1.swift
//  Accountant
//
//  Created by Roman Topchii on 13.06.2021.
//

import UIKit

class TransactionTableViewCell1: UITableViewCell {
    @IBOutlet weak var view : UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var debitLabel: UILabel!
    @IBOutlet weak var creditAmountLabel: UILabel!
    @IBOutlet weak var debitAmountLabel: UILabel!
    
    
    private var credit: Account!
    private var debit: Account!
    private var creditCurrency: Currency!
    private var debitCurrency: Currency!
    private var creditName : String = ""
    private var debitName : String = ""
    private var debitAmount: Double!
    private var creditAmount: Double!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateCell(transaction : Transaction) {
        guard let date = transaction.date,
              let items = transaction.items?.allObjects as? [TransactionItem]
        else {return}
        
        for item in items {
            if item.type == AccounttingMethod.debit.rawValue {
                debit = item.account
                debitAmount = item.amount
                debitName = debit.path!
                debitCurrency = debit.currency
            }
            else if item.type == AccounttingMethod.credit.rawValue {
                credit = item.account
                creditAmount = item.amount
                creditName = credit.path!
                creditCurrency = credit.currency
            }
        }
       
     
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd"
        dayLabel.text = formatter.string(from: date)
        dayLabel.textColor = .systemBlue
        dayLabel.alpha = 0.8
        
        formatter.dateFormat = "MM"
        monthLabel.text = formatter.string(from: date)
        monthLabel.textColor = .systemBlue
        monthLabel.alpha = 0.8
        
        creditLabel.text = "\(NSLocalizedString("From:", comment: "")) \(creditName)"
        debitLabel.text = "\(NSLocalizedString("To:", comment: "")) \(debitName)"
        
        
        if debitCurrency == creditCurrency {
            creditAmountLabel.text = cutNumber(creditAmount) + creditCurrency.code!
            debitAmountLabel.isHidden = true
        }
        else {
            debitAmountLabel.isHidden = false
            creditAmountLabel.text = cutNumber(creditAmount) + creditCurrency.code!
            debitAmountLabel.text = cutNumber(debitAmount) + debitCurrency.code!
        }
        
        let debitRootName = AccountManager.getRootAccountFor(debit).name
        let creditRootName = AccountManager.getRootAccountFor(credit).name
        
        if creditRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.income) &&
           debitRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) {
            view.backgroundColor = UIColor(red: 192/255.0, green: 255/255.0, blue: 140/255.0, alpha: 0.5)
        }
        else  if creditRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) &&
                 debitRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.expense) {
            view.backgroundColor = UIColor(red: 230/255.0, green: 140/255.0, blue: 157/255.0, alpha: 0.5)
        }
        else  if creditRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) &&
                 debitRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) {
            view.backgroundColor = UIColor(displayP3Red: 13/255, green: 4/255, blue: 130/255, alpha: 0.1)
        }
        else {
            view.backgroundColor = .systemBackground
        }
    }
    
    func cutNumber(_ number : Double) -> String {
        var amount : String
        if abs(number) >= 1_000_000_000  {
            amount = "\(round(number / 100_000_000)/10)B "
        }
        else if abs(number) >= 1_000_000 && abs(number) < 1_000_000_000 {
            amount = "\(round(number / 100_000)/10)M "
        }
        else if abs(number) >= 100_000 && abs(number) < 1_000_000 {
             amount = "\(round(number / 100)/10)K "
        }
        else {
            amount = "\(Int(number)) "
        }
        return amount
    }
}
