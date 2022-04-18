//
//  ProBadgeView.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//

import UIKit

class BadgeView: UIView {

    private var gradientView: GradientView!

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let width = CGFloat(39)
    private let height = CGFloat(22)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.heightAnchor.constraint(equalToConstant: self.height).isActive = true
        self.widthAnchor.constraint(equalToConstant: self.width).isActive = true
    }

    func proBadge() {
        label.text = "PRO".uppercased()
        
        // The Gradient subview
        if gradientView != nil {
            gradientView.removeFromSuperview()
        }
        self.gradientView = GradientView(frame: self.bounds, colorTop: .systemPink, colorBottom: .systemRed)
        self.gradientView.layer.cornerRadius = height/2
        self.insertSubview(gradientView, at: 0)
        self.layer.masksToBounds = false
        
        // The Label subview
        gradientView.addSubview(label)
        let horizontalConstraint = NSLayoutConstraint(item: label,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: gradientView,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: label,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: gradientView,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }
    
    func monoBadge() {
        label.text = "Mono"
        label.font = UIFont.boldSystemFont(ofSize: 10)

        // The Gradient subview
        if gradientView != nil {
            gradientView.removeFromSuperview()
        }
        self.gradientView = GradientView(frame: self.bounds, colorTop: .black, colorBottom: .darkGray)
        self.gradientView.layer.cornerRadius = height/2
        self.insertSubview(gradientView, at: 0)
        self.layer.masksToBounds = false

        // The Label subview
        gradientView.addSubview(label)
        let horizontalConstraint = NSLayoutConstraint(item: label,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: gradientView,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: label,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: gradientView,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }

    func exchangeBadge() {
        label.text = "💹"
        label.font = UIFont.boldSystemFont(ofSize: 30)

        // The Gradient subview
        if gradientView != nil {
            gradientView.removeFromSuperview()
        }
        self.gradientView = GradientView(frame: self.bounds, colorTop: .clear, colorBottom: .clear)
        self.gradientView.layer.cornerRadius = height/2
        self.insertSubview(gradientView, at: 0)
        self.layer.masksToBounds = false

        // The Label subview
        gradientView.addSubview(label)
        let horizontalConstraint = NSLayoutConstraint(item: label,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: gradientView,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: label,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: gradientView,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1, constant: 0)

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
