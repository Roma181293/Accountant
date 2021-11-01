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
        imageView.image = UIImage(named: "account-swipe")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let label : UILabel = {
        let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
    }
    
    
    func addAccountInstruction() {
        let descriptionArray: [(String,UIColor,String)] = [
            ("plus",UIColor.systemGreen,"Add subcategory to the selected category"),
            ("pencil",UIColor.systemBlue,"Rename selected category/account"),
            ("trash",UIColor.systemRed,"Delete selected category/account"),
            ("eye.slash",UIColor.systemGray,"Hide selected category/account"),
            ("eye",UIColor.systemIndigo,"Unhide selected category/account")]
        
        
        self.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        //MARK: - Description Stack View
        descriptionArray.forEach({item in
            let descriptionItemStackView: UIStackView = {
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
            descriptionItemStackView.addArrangedSubview(backGroundView)
            descriptionItemStackView.addArrangedSubview(descriptionLabel)
            stackView.addArrangedSubview(descriptionItemStackView)

        })
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
