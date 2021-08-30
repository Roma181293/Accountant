//
//  ComplexTransactionTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 29.08.2021.
//

import UIKit

class ComplexTransactionTableViewCell: UITableViewCell {

    unowned var transaction: Transaction!
    
    private var itemViewArray: [UIView] = []
    private var firstLaunch: Bool = true
    
    let mainView : UIView = {
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.layer.borderWidth = 0.5
        mainView.layer.borderColor = UIColor.systemGray.cgColor//UIColor.systemBlue.cgColor.copy(alpha: 0.3)
        
//        mainView.layer.shadowColor = UIColor.lightGray.cgColor
//        mainView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        mainView.layer.shadowRadius = 4.0
//        mainView.layer.shadowOpacity = 4.0
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()
    
    let mainStackView : UIStackView = {
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
        label.textColor = .label
        label.alpha = 1
//        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let debitStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let creditStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let debitItemsStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let creditItemsStackView : UIStackView = {
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
        label.text = "  " + NSLocalizedString("To:", comment: "") + "  "
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.systemGray.cgColor//UIColor.systemBlue.cgColor.copy(alpha: 0.3)
        label.layer.backgroundColor = UIColor.systemGray.cgColor//UIColor.systemBlue.cgColor.copy(alpha: 0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let creditLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + NSLocalizedString("From:", comment: "") + "  "
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.systemGray.cgColor//UIColor.systemBlue.cgColor.copy(alpha: 0.3)
        label.layer.backgroundColor = UIColor.systemGray.cgColor//UIColor.systemBlue.cgColor.copy(alpha: 0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    
    func setMainView(){
        guard firstLaunch else {return}
        firstLaunch = !firstLaunch
        
        //MARK:- Main View
        contentView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        
        //MARK:- Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 6).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -6).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -8).isActive = true
        
        mainStackView.addArrangedSubview(dateLabel)
        
        dateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        //MARK:- Credit content
        mainStackView.addArrangedSubview(creditStackView)
        
        creditStackView.addArrangedSubview(creditLabel)
        creditLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        creditLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        creditStackView.addArrangedSubview(creditItemsStackView)
        
        
        //MARK:- Debit content
        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitLabel)
        debitLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        debitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        debitStackView.addArrangedSubview(debitItemsStackView)

    }
    
    
    func setTransaction(_ transaction : Transaction) {
        self.transaction = transaction
        guard let date = transaction.date,
              let items = transaction.items?.allObjects as? [TransactionItem]
        else {return}
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
        dateLabel.text = formatter.string(from: date)
        
        itemViewArray.forEach({$0.removeFromSuperview()})
        
        for item in items {
            
            let itemView = UIView()
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            let accountPathLabel = UILabel()
            accountPathLabel.text = item.account!.path
            accountPathLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let amountAndCurrencyLabel = UILabel()
            amountAndCurrencyLabel.text = cutNumber(item.amount) + item.account!.currency!.code!
            amountAndCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            itemView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            itemView.addSubview(accountPathLabel)
            accountPathLabel.leadingAnchor.constraint(equalTo: itemView.leadingAnchor).isActive = true
            accountPathLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor).isActive = true
            
       
            itemView.addSubview(amountAndCurrencyLabel)
//            amountLabel.leadingAnchor.constraint(equalTo: accountPathLabel.trailingAnchor, constant: 8).isActive = true
            let widthMax = amountAndCurrencyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
            widthMax.priority = UILayoutPriority(1)
            widthMax.isActive = true
            
            let widthMin = amountAndCurrencyLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
            widthMin.priority = UILayoutPriority(2)
            widthMin.isActive = true
            
            amountAndCurrencyLabel.trailingAnchor.constraint(equalTo: itemView.trailingAnchor).isActive = true
            amountAndCurrencyLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor).isActive = true
            
            
            if item.type == AccounttingMethod.debit.rawValue {
                debitItemsStackView.addArrangedSubview(itemView)
            }
            else if item.type == AccounttingMethod.credit.rawValue {
                creditItemsStackView.addArrangedSubview(itemView)
            }
            itemViewArray.append(itemView)
        }
        
       
        setMainView()
        
     
        
        
        
        

        let debitRootName = AccountManager.getRootAccountFor(items.filter({$0.type == AccounttingMethod.debit.rawValue})[0].account!).name
        let creditRootName = AccountManager.getRootAccountFor(items.filter({$0.type == AccounttingMethod.credit.rawValue})[0].account!).name

        if creditRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.income) &&
           debitRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) {
            mainView.backgroundColor = UIColor(cgColor: UIColor.systemGreen.cgColor.copy(alpha: 0.3)!)
        }
        else  if creditRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) &&
                 debitRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.expense) {
            mainView.backgroundColor = UIColor(cgColor: UIColor.systemPink.cgColor.copy(alpha: 0.3)!)
        }
        else  if creditRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) &&
                 debitRootName == AccountsNameLocalisationManager.getLocalizedAccountName(.money) {
            mainView.backgroundColor = UIColor(cgColor: UIColor.systemTeal.cgColor.copy(alpha: 0.3)!)
        }
        else {
            mainView.backgroundColor = UIColor(cgColor: UIColor.systemGray2.cgColor.copy(alpha: 0.3)!)
        }
    }
    
    
    
    private func cutNumber(_ number : Double) -> String {
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
