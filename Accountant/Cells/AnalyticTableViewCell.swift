//
//  AnalyticTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 01.09.2021.
//

import UIKit

class AnalyticTableViewCell: UITableViewCell {
 
    let indicatorColorView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let amountLabel : UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emptySpaceStackView : UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emptySpaceView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    func configureCell(for accountData: AccountData, account: Account, accountingCurrency: Currency) {
        indicatorColorView.backgroundColor = accountData.color
        if accountData.amountInAccountingCurrency < 0 {
            self.accessoryType = .detailButton
            amountLabel.textColor = .red
            emptySpaceView.isHidden = true
        }
        else if let children = accountData.account.children, children.count > 0, account != accountData.account {
            self.accessoryType = .disclosureIndicator
            amountLabel.textColor = Colors.Main.defaultCellTextColor
            emptySpaceView.isHidden = true
        }
        else {
            self.accessoryType = .none
            amountLabel.textColor =  Colors.Main.defaultCellTextColor
            emptySpaceView.isHidden = false
        }
        
        titleLabel.text = accountData.title
        
        if let currency = accountData.account.currency {
            amountLabel.text = "\(round(accountData.amountInAccountCurrency*100)/100) \(currency.code!)"
        }
        else {
            amountLabel.text = "\(round(accountData.amountInAccountingCurrency*100)/100) \(accountingCurrency.code!)"
        }
        
        //MARK:- Adding constraints
        contentView.addSubview(indicatorColorView)
        indicatorColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        indicatorColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        indicatorColorView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        indicatorColorView.heightAnchor.constraint(equalToConstant: 9).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: indicatorColorView.trailingAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(amountLabel)
        amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(emptySpaceStackView)
        emptySpaceStackView.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 8).isActive = true
        emptySpaceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        emptySpaceStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        emptySpaceStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        emptySpaceStackView.addArrangedSubview(emptySpaceView)
        emptySpaceView.widthAnchor.constraint(equalToConstant: 30.5).isActive = true
    }
}
