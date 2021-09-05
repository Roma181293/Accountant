//
//  StatusBarAnimationViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//

import Foundation
import UIKit

protocol StatusBarAnimationViewController: class {
  var statusBarShouldBeHidden: Bool { get set }
  var statusBarAnimationStyle: UIStatusBarAnimation { get set }
}

extension StatusBarAnimationViewController where Self: UIViewController {
  
    func updateStatusBarAppearance(hidden: Bool, withDuration duration: Double = 0.3, completion: ((Bool) -> Void)? = nil) {
        //statusBarShouldBeHidden = hidden
        if #available(iOS 13.0, *) {
        } else {
            UIView.animate(withDuration: duration, animations: { [weak self] in
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.backgroundColor = UIColor.clear
                //self?.setNeedsStatusBarAppearanceUpdate()
            }, completion: completion)
        }
    }
}
