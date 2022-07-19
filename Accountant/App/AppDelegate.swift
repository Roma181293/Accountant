//
//  AppDelegate.swift
//  Accountant
//
//  Created by Roman Topchii on 01.06.2021.
//

import UIKit
import Purchases

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { // swiftlint:disable:this line_length

        // MARK: REVENUECAT initializing
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: Constants.APIKey.revenueCat)

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let additionalVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.additionalLaunchScreenVC) as? AdditionalLaunchScreenViewController else {return true} // swiftlint:disable:this line_length
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = additionalVC

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if UserProfile.getUserAuth() != .none {
            UserProfile.setAppBecomeBackgroundDate(Date())
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let calendar = Calendar.current

        // MARK: - GET PURCHASER INFO
        if let lastAccessCheckDate = UserProfile.getLastAccessCheckDate(),
           let secureDate = calendar.date(byAdding: .hour, value: 6, to: lastAccessCheckDate),
               secureDate > Date() {
            Purchases.shared.purchaserInfo { (purchaserInfo, _) in
                if purchaserInfo?.entitlements.all["pro"]?.isActive == false,
                   let expirationDate = purchaserInfo?.expirationDate(forEntitlement: "pro"),
                   let secureDate = calendar.date(byAdding: .day, value: 3, to: expirationDate),
                   secureDate < Date() {
                    UserProfile.setUserAuth(.none)
                }
                NotificationCenter.default.post(name: .receivedProAccessData, object: nil)
                UserProfile.setLastAccessCheckDate()
            }
        }

        // MARK: - AUTH BLOCK
        let userAuthType = UserProfile.getUserAuth()
        if userAuthType == .bioAuth {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            guard let authVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.bioAuthVC) as? BiometricAuthViewController else {return} // swiftlint:disable:this line_length
            authVC.previousNavigationStack = window?.rootViewController
            window = UIWindow(frame: UIScreen.main.bounds)

            if let appBecomeBackgroundDate = UserProfile.getAppBecomeBackgroundDate() {
                if let secureDate = calendar.date(byAdding: .second, value: 120,
                                                  to: appBecomeBackgroundDate), secureDate < Date() {
                    window?.makeKeyAndVisible()
                    window?.rootViewController = authVC
                } else {
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController) // swiftlint:disable:this line_length
                    window?.makeKeyAndVisible()
                    window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            } else {
                window?.makeKeyAndVisible()
                window?.rootViewController = authVC
            }
        }
    }
}
