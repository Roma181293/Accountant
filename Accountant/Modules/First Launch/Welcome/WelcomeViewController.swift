//
//  WelcomeViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.09.2021.
//

import UIKit

class WelcomeViewController: UIViewController {

    private lazy var mainView: WelcomeView = {return WelcomeView(controller: self)}()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mainView.startAccountingButton.isUserInteractionEnabled = true
        mainView.testButton.isUserInteractionEnabled = true
    }

    @objc func startAccounting(_ sender: UIButton) {
        mainView.startAccountingButton.isUserInteractionEnabled = false
        mainView.testButton.isUserInteractionEnabled = false
        self.navigationController?.pushViewController(StartAccountingViewController(), animated: true)
    }

    @objc func tryFunctionality(_ sender: UIButton) {
        mainView.startAccountingButton.isUserInteractionEnabled = false
        mainView.testButton.isUserInteractionEnabled = false
        CoreDataStack.shared.switchToDB(.test)
        do {
            try SeedDataService.refreshTestData(coreDataStack: CoreDataStack.shared)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
            self.navigationController?.popToRootViewController(animated: false)

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
        } catch let error {
            errorHandler(error: error)
        }
    }

    func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error",
                                                               tableName: Constants.Localizable.welcomeVC,
                                                               comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.welcomeVC,
                                                               comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
