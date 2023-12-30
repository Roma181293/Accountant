//
//  PlaceholderViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.07.2022.
//

import Foundation
import UIKit

class AdditionalLaunchScreenViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoreWillLoad),
                                               name: .persistentStoreWillLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(persistentStoreDidLoad),
                                               name: .persistentStoreDidLoad, object: nil)

        let coreDataStack = CoreDataStack.shared
        coreDataStack.configureContainerFor(.prod)
        coreDataStack.loadPersistentStores()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .persistentStoreWillLoad, object: nil)
        NotificationCenter.default.removeObserver(self, name: .persistentStoreDidLoad, object: nil)
    }

    @objc func persistentStoreWillLoad() {
        activityIndicator.startAnimating()
    }

    @objc func persistentStoreDidLoad() {
        activityIndicator.stopAnimating()

        // MARK: Loading exchange rates
        if UserProfileService.isAppLaunchedBefore() {
            let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
            ExchangeRatesLoader.load(context: context)
        }
        NetworkServices.loadCurrency(date: Date()) { (currencyHistoricalData, _) in
            if let currencyHistoricalData = currencyHistoricalData {
                DispatchQueue.main.async {
                    UserProfileService.setExchangeRate(currencyHistoricalData)
                }
            }
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        if !UserProfileService.isAppLaunchedBefore() {
            appDelegate.window?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
            appDelegate.window?.makeKeyAndVisible()
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if UserProfileService.getUserAuth() == .bioAuth {
                guard let authVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.bioAuthVC) as? BiometricAuthViewController else {return}  // swiftlint:disable:this line_length
                appDelegate.window?.rootViewController = authVC
                appDelegate.window?.makeKeyAndVisible()
            } else {
                let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
                self.navigationController?.popToRootViewController(animated: false)
                appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
            }
        }
    }
}
