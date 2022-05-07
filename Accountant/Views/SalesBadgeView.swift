//
//  SalesBadgeView.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//

import UIKit

class SalesBadgeView: UIView {

    let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    let height = CGFloat(18)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.heightAnchor.constraint(equalToConstant: self.height).isActive = true

        // The Gradient subview
        let gradientOrangeView = GradientView(frame: self.bounds, colorTop: .systemBlue, colorBottom: .systemPurple)
        gradientOrangeView.layer.cornerRadius = height/2
        self.insertSubview(gradientOrangeView, at: 0)
        self.layer.masksToBounds = false
        
        // The Label subview
        gradientOrangeView.addSubview(label)
        let horizontalConstraint = NSLayoutConstraint(item: label,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: gradientOrangeView,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: label,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: gradientOrangeView,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
