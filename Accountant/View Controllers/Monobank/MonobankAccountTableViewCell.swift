//
//  MonobankAccountTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 18.12.2021.
//

import UIKit

class MonobankAccountTableViewCell: UITableViewCell {

    let mainStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let additionalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let balanceLabel : UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let creditLimitLabel : UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let statusLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "blackGrayColor")
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    func configureCell(_ mbba: MBAccountInfo, isAdded: Bool){
        contentView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        mainStackView.addArrangedSubview(additionalStackView)
        additionalStackView.addArrangedSubview(nameLabel)
        additionalStackView.addArrangedSubview(statusLabel)
        
        mainStackView.addArrangedSubview(balanceLabel)
        mainStackView.addArrangedSubview(creditLimitLabel)
        
        let currency = mbba.getCurrency(context: CoreDataStack.shared.persistentContainer.viewContext)?.code ?? "Unknown currency"
        
        if isAdded {
            statusLabel.text = "  " + NSLocalizedString("Already added", comment: "") + "  "
            statusLabel.layer.backgroundColor = UIColor.green.cgColor
        }
        else {
            statusLabel.text = "  " + NSLocalizedString("Will be adding", comment: "") + "  "
            statusLabel.layer.backgroundColor = UIColor.orange.cgColor
        }
        
        nameLabel.text = mbba.maskedPan.last
        balanceLabel.text = NSLocalizedString("Balance", comment: "") + " " + String(Double(mbba.balance)/100.0) + " " + currency
        creditLimitLabel.text = NSLocalizedString("Credit limit", comment: "") + " " + String(Double(mbba.creditLimit)/100.0) + " " + currency
    }
}
