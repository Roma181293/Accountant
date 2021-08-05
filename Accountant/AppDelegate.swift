//
//  AppDelegate.swift
//  Accountant
//
//  Created by Roman Topchii on 01.06.2021.
//

import UIKit
import Purchases
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //MARK: Subscriprion
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: Constants.APIKey.revenueCat)
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                UserProfile.setEntitlement(Entitlement(name: .pro, expirationDate: purchaserInfo?.entitlements.all["pro"]?.expirationDate))
            }
            else {
                UserProfile.setEntitlement(Entitlement(name: .none, expirationDate: purchaserInfo?.entitlements.all["pro"]?.expirationDate))
            }
            print(UserProfile.getEntitlement())
        }
        
        //MARK:GOOGLE ADD initializing
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //MARK: Loading exchange rates
        NetworkServices.loadCurrency(date: Date()) { (currencyHistoricalData, error) in
            if let currencyHistoricalData = currencyHistoricalData {
                DispatchQueue.main.async {
                    UserProfile.setExchangeRate(currencyHistoricalData)
                    print("Done. Exchange rate loaded")
                }
            }
        }
        
        //MARK: Check is app launched before
        if !UserProfile.isAppLaunchedBefore() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let setNameVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.setAccountingStartDateViewController) as! SetAccountingStartDateViewController
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            window?.rootViewController = UINavigationController(rootViewController: setNameVC)
        }
        else if UserProfile.getUserAuth() == .bioAuth {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.bioAuthViewController) as! BiometricAuthViewController
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            window?.rootViewController = authVC
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application : UIApplication) {
        if UserProfile.getUserAuth() != .none {
            UserProfile.setAppBecomeBackgroundDate(Date())
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        let userAuthType = UserProfile.getUserAuth()
        let calendar = Calendar.current
        if userAuthType == .bioAuth {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.bioAuthViewController) as! BiometricAuthViewController
            authVC.previousNavigationStack = window?.rootViewController
            window = UIWindow(frame: UIScreen.main.bounds)
            
            if let appBecomeBackgroundDate = UserProfile.getAppBecomeBackgroundDate() {
                if let secureDate = calendar.date(byAdding: .second, value: 120, to: appBecomeBackgroundDate), secureDate < Date() {
                    window?.makeKeyAndVisible()
                    window?.rootViewController = authVC
                }
                else {
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
                    window?.makeKeyAndVisible()
                    window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            }
            else {
                window?.makeKeyAndVisible()
                window?.rootViewController = authVC
            }
        }
        else if userAuthType == .appAuth {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.authPinAndBioViewController) as! AuthPinAndBiometricViewController
            authVC.previousNavigationStack = window?.rootViewController
            window = UIWindow(frame: UIScreen.main.bounds)
            if let appBecomeBackgroundDate = UserProfile.getAppBecomeBackgroundDate() {
                if let secureDate = calendar.date(byAdding: .second, value: 120, to: appBecomeBackgroundDate), secureDate < Date() {
                    window?.makeKeyAndVisible()
                    window?.rootViewController = authVC
                }
                else {
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
                    window?.makeKeyAndVisible()
                    window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            }
            else {
                window?.makeKeyAndVisible()
                window?.rootViewController = authVC
            }
        }
    }
}
