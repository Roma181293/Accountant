//
//  BiometricAuthViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 04.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricAuthViewController: UIViewController {

    @IBOutlet weak var biometryAuthButton: UIButton!

    var previousNavigationStack: UIViewController?

    var context = LAContext()

    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        didSet {
            if state == .loggedin, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                UserProfileService.setAppBecomeBackgroundDate(nil)
                if let previousNavigationStack = previousNavigationStack {
                    appDelegate.window?.rootViewController = previousNavigationStack
                } else {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: "TabBarController_ID")
                    self.navigationController?.popToRootViewController(animated: false)
                    appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            if context.biometryType == .faceID {
                biometryAuthButton.setImage(UIImage(systemName: "faceid"), for: .normal)
            } else if context.biometryType == .touchID {
                biometryAuthButton.setImage(UIImage(systemName: "touchid"), for: .normal)
            } else if context.biometryType == .none {
                print(".none")
            }
            biometryAuthButton.isHidden = true
            biometryAuthentication()
        }
    }

    @IBAction func biometryAuthentication() {
        context.localizedCancelTitle = NSLocalizedString("Cancel", comment: "")
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            biometryAuthButton.isHidden = true
            let reason = NSLocalizedString("to activate", comment: "")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ) { success, error in
                if success {
                    DispatchQueue.main.async { [unowned self] in
                        self.state = .loggedin
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    DispatchQueue.main.async { [unowned self] in
                        biometryAuthButton.isHidden = false
                    }
                }
            }
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
        }
    }
}
