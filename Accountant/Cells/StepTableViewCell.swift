//
//  StepTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 11.09.2021.
//

import UIKit

class StepTableViewCell: UITableViewCell {

    var account: Account!
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let checkMarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    func configureCell(_ item: (account: Account, done: Bool)) {
        self.account = item.account
        contentView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(checkMarkImageView)
        (checkMarkImageView).trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        (checkMarkImageView).centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        
        titleLabel.text = item.account.path!
        
    
        if item.done == true || account.children?.count != 0 {
            checkMarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            checkMarkImageView.tintColor = .systemGreen
        }
        else {
            checkMarkImageView.image = UIImage(systemName: "circle")
            checkMarkImageView.tintColor = .systemGray
        }
    }
}
