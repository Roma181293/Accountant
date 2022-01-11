//
//  GradientView.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//

import Foundation

import Foundation
import UIKit

class GradientView: UIButton {

    private var colorTop: UIColor?
    private var colorBottom: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Default values for gradient colors
        self.colorTop = UIColor.white
        self.colorBottom = UIColor.white
        setupView()
    }
    
    init(frame: CGRect, colorTop: UIColor, colorBottom: UIColor) {
        super.init(frame: frame)
        self.colorTop = colorTop
        self.colorBottom = colorBottom
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let gradientLayer = self.layer as? CAGradientLayer else { return }

        gradientLayer.colors = [self.colorTop!.cgColor, self.colorBottom!.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = Constants.Size.cornerButtonRadius
        gradientLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}
