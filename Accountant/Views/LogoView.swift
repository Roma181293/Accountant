//
//  LogoView.swift
//  Accountant
//
//  Created by Roman Topchii on 28.09.2021.
//

import UIKit

class LogoView: UIView {

    let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "My\nBudget"
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 50)
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
        let gradientOrangeView = GradientView(frame: self.bounds, colorTop: .systemGray4, colorBottom: .systemGray6)
        gradientOrangeView.layer.cornerRadius = height/2
        self.insertSubview(gradientOrangeView, at: 0)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 2.0
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



//
//  GradientView.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//
//
//import Foundation
//
//import Foundation
//import UIKit
//
//class GradientView: UIButton {
//
//    var colorTop: UIColor?
//    var colorBottom: UIColor?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        //Default values for gradient colors
//        self.colorTop = UIColor.white
//        self.colorBottom = UIColor.white
//        setupView()
//    }
//
//    init(frame: CGRect, colorTop: UIColor, colorBottom: UIColor) {
//        super.init(frame: frame)
//        self.colorTop = colorTop
//        self.colorBottom = colorBottom
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//
//    private func setupView() {
//        autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
//
//        gradientLayer.colors = [self.colorTop!.cgColor, self.colorBottom!.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.locations = [0.1, 0.5]
//        gradientLayer.cornerRadius = Constants.Size.cornerButtonRadius
//        gradientLayer.frame = self.bounds
//    }
//
//    override class var layerClass: AnyClass {
//        return CAGradientLayer.self
//    }
//}
