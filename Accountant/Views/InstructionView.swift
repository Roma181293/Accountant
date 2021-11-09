//
//  InstructionView.swift
//  Accountant
//
//  Created by Roman Topchii on 31.10.2021.
//

import UIKit

class InstructionView: UIView {

    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "editCategory")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let descriptionItemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
//        mainStackView.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor).isActive = true
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(imageView)
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180).isActive = true
        
        mainStackView.addArrangedSubview(descriptionItemStackView)
    }
    
    func editAccountStructure() {
        titleLabel.text = "Change category/account structure"
        let descriptionArray: [(String,UIColor,String)] = [
            ("plus",UIColor.systemGreen,"Add subcategory to the selected category"),
            ("pencil",UIColor.systemBlue,"Rename selected category/account"),
            ("trash",UIColor.systemRed,"Delete selected category/account"),
            ("eye.slash",UIColor.systemGray,"Hide selected category/account"),
            ("eye",UIColor.systemIndigo,"Unhide selected category/account")]
        
        
        //MARK: - Description Stack View
        descriptionArray.forEach({item in
            let itemStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .fill
                stackView.distribution = .fill
                stackView.spacing = 8.0
                stackView.backgroundColor = UIColor(white: 1, alpha: 0)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                return stackView
            }()
            
            let backGroundView: UIView = {
                let backGroundView = UIView()
                backGroundView.backgroundColor = item.1
                backGroundView.translatesAutoresizingMaskIntoConstraints = false
                return backGroundView
            }()
            
            let imageView: UIImageView = {
                let imageView = UIImageView()
                imageView.image = UIImage(systemName: item.0)
                imageView.tintColor = .white
                imageView.translatesAutoresizingMaskIntoConstraints = false
                return imageView
            }()
            
            let descriptionLabel: UILabel = {
                let label = UILabel()
                label.textAlignment = .left
                label.text = NSLocalizedString(item.2, comment: "")
                label.textColor = .label
                label.font = UIFont.systemFont(ofSize: 16.0)
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            
            backGroundView.addSubview(imageView)
            imageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor).isActive = true
            imageView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor).isActive = true
            
            backGroundView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            backGroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            descriptionLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 360).isActive = true
            itemStackView.addArrangedSubview(backGroundView)
            itemStackView.addArrangedSubview(descriptionLabel)
            descriptionItemStackView.addArrangedSubview(itemStackView)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
