//
//  ProBadgeUIView.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//

import UIKit

class ProBadgeUIView: UIView {

    let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "PRO".uppercased()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let width = CGFloat(39)
    let height = CGFloat(22)
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.heightAnchor.constraint(equalToConstant: self.height).isActive = true
        self.widthAnchor.constraint(equalToConstant: self.width).isActive = true

        //The Gradient subview
        let gradientOrangeView = GradientView(frame: self.bounds, colorTop: .systemPink, colorBottom: .systemRed)
        gradientOrangeView.layer.cornerRadius = height/2
        self.insertSubview(gradientOrangeView, at: 0)
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowRadius = 2.0
//        self.layer.shadowOpacity = 2.0
        self.layer.masksToBounds = false
        
        //The Label subview
        gradientOrangeView.addSubview(label)
        let horizontalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: gradientOrangeView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: gradientOrangeView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }
    
    func getWidth() -> CGFloat {
        return self.width
    }
    
    func getHeight() -> CGFloat {
        return self.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
