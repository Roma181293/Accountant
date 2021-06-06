//
//  Extension UIScrollView.swift
//  Accounting
//
//  Created by Roman Topchii on 04.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToLeft(animated: Bool) {
        let leftOffset = CGPoint(x: -contentInset.left, y:0)
        setContentOffset(leftOffset, animated: animated)
    }
}
