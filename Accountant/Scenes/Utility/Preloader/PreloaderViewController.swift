//
//  PreloaderViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.07.2022.
//

import Foundation
import UIKit

class PreloaderViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true

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
        if RemoteConfigValues.shared.fetchComplete {
            launchApp()
        }

        RemoteConfigValues.shared.loadingDoneCallback = launchApp
    }

    func launchApp() {
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

        // Check if its required and possible to update the app
        if let dictionary = Bundle.main.infoDictionary,
           let buildString = dictionary["CFBundleVersion"] as? String,
           let build = Int(buildString),
           RemoteConfigValues.shared.getLatestAppBuild() > build {

            NetworkMonitor.shared.startMonitoring()

            // Propose to update only if user have inthernet
            if NetworkMonitor.shared.isReachable, !NetworkMonitor.shared.isExpensive {
                NetworkMonitor.shared.stopMonitoring()
                UserProfileService.increaseShowUpdateAppCount()
                showUpdateAppAlert(isMandatoryUpdate: UserProfileService.isRequiredUpdate())
            } else {
                NetworkMonitor.shared.stopMonitoring()
                showContent()
            }
        } else {
            UserProfileService.resetNeedUpdate()
            showContent()
        }
    }

    func showUpdateAppAlert(isMandatoryUpdate: Bool) {
        let alert = UIAlertController(
            title: NSLocalizedString("New app version",
                                     tableName: Constants.Localizable.preloaderVC,
                                     comment: ""),
            message: NSLocalizedString("Please update app to the latest version",
                                       tableName: Constants.Localizable.preloaderVC,
                                       comment: ""),
            preferredStyle: .alert)

        let okButton = UIAlertAction(title: NSLocalizedString("Update",
                                                              tableName: Constants.Localizable.preloaderVC,
                                                              comment: ""),
                                     style: .default) { (_) in
            guard let url = URL(string: Constants.URL.appStoreProduct) else {return}
            UIApplication.shared.open(url)
        }
        alert.addAction(okButton)

        if !isMandatoryUpdate {
            alert.addAction(
                UIAlertAction(title: NSLocalizedString("Cancel",
                                                       tableName: Constants.Localizable.preloaderVC,
                                                       comment: ""),
                              style: .cancel) {[weak self] (_) in
                                  self?.showContent()
                              })
        }
        self.present(alert, animated: true)
    }

    private func showContent() {
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

        NotificationCenter.default.removeObserver(self, name: .persistentStoreWillLoad, object: nil)
        NotificationCenter.default.removeObserver(self, name: .persistentStoreDidLoad, object: nil)
    }
}
