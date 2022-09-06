//
//  CurrencyTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 22.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func configure(_ fetchedCurrency: Currency, currency: Currency?, mode: CurrencyViewController.Mode) {
        contentView.addSubview(codeLabel)
        codeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        codeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        codeLabel.widthAnchor.constraint(equalToConstant: 45).isActive = true

        contentView.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: 15).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        if mode == .setAccountingCurrency {
            if fetchedCurrency.isAccounting {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        } else if mode == .setCurrency {
            if currency === fetchedCurrency {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }

        codeLabel.text = fetchedCurrency.code
        if let name = fetchedCurrency.name {
            nameLabel.text = name
        } else {
            nameLabel.text = NSLocalizedString(fetchedCurrency.code, comment: "")
        }
    }
}
