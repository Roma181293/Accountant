//
//  WelcomeViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.09.2021.
//

import UIKit

class WelcomeViewController: UIViewController {

    private lazy var mainView: WelcomeView = {return WelcomeView(controller: self)}()
    private lazy var viewModel = WelcomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchIsUserInteractionEnabled(to: true)
    }

    @objc func startAccounting(_ sender: UIButton) {
        switchIsUserInteractionEnabled(to: false)
        self.navigationController?.pushViewController(StartAccountingViewController(), animated: true)
    }

    @objc func tryFunctionality(_ sender: UIButton) {
        switchIsUserInteractionEnabled(to: false)

        do {
            try viewModel.switchToTestData()

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
            self.navigationController?.popToRootViewController(animated: false)

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
        } catch let error {
            errorHandler(error: error)
        }
    }

    private func switchIsUserInteractionEnabled(to value: Bool) {
        mainView.startAccountingButton.isUserInteractionEnabled = value
        mainView.testButton.isUserInteractionEnabled = value
    }

    private func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error",
                                                               tableName: Constants.Localizable.welcome,
                                                               comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.welcome,
                                                               comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
