//
//  WebViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.09.2021.
//

import UIKit
import WebKit
import SafariServices

class WebViewController: SFSafariViewController {

    var targetUrl: URL?
    var statusBarShouldBeHidden = false
    var statusBarAnimationStyle: UIStatusBarAnimation = .slide

    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimationStyle
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override var shouldAutorotate: Bool {
        return false
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
        }
    }
}
