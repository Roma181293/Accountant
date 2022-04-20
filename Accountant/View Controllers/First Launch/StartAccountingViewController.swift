//
//  StartAccountingViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.09.2021.
//

import UIKit

class StartAccountingViewController: UIViewController { // swiftlint:disable:this type_body_length

    var coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext

    weak var currencyTVC: CurrencyViewController!
    var accountNavigationTVC: AccountNavigatorTableViewController!
    weak var backToVC: UIViewController?

    var currentStep = 0
    var currency: Currency?

    // swiftlint:disable line_length
    var workFlowTitleArray = [
        NSLocalizedString("Choose currecy for Income and Expenses categories. This currency cannot be changed in the future", comment: ""),
        NSLocalizedString("Add Monobank bank profile, to sync statements data. All the data stores only on this device locally", comment: ""),
        NSLocalizedString("Please add income categories", comment: ""),
        NSLocalizedString("Please add expense categories", comment: ""),
        NSLocalizedString("Please add money accounts (Cash and bank cards). \nDo NOT enter secure info about bank cards(full card number and CV2 code)", comment: ""),
        NSLocalizedString("Please add debtors. Debtors also include bank deposits", comment: ""),
        NSLocalizedString("Please add credits. Credit card limits are automatically added to credits", comment: "")]
    // swiftlint:enable line_length

    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Size.cornerCardRadius
        view.layer.backgroundColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let addBankProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Go to bank profiles", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.Main.confirmButton
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.Main.confirmButton
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Accounting start", comment: "")
        CoreDataStack.shared.switchToDB(.prod)
        context = CoreDataStack.shared.persistentContainer.viewContext
        do {
            if UserProfile.isAppLaunchedBefore() == false {
                // remove old test Data
                try SeedDataManager.clearAllTestData(coreDataStack: CoreDataStack.shared)
            }
            // add New Data
            try SeedDataManager.createCurrenciesHoldersKeepers(coreDataStack: CoreDataStack.shared)
        } catch let error {
            errorHandler(error: error)
        }
        addMainView()
        addCurrencyTVC()
        titleLabel.text = workFlowTitleArray[currentStep]
        nextButton.addTarget(self, action: #selector(self.nextStep), for: .touchUpInside)
    }

    deinit {
        if backToVC != nil && UserProfile.isAppLaunchedBefore() == false {
            CoreDataStack.shared.switchToDB(.test)
            NotificationCenter.default.post(name: .environmentDidChange, object: nil)
        }
    }

    private func addMainView() {

        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainView.addSubview(cardView)
        cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8).isActive = true
        cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8).isActive = true
        cardView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true

        cardView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 110).isActive = true

        mainView.addSubview(addButton)
        addButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true

        view.addSubview(nextButton)
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -89).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                             constant: -40).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }

    @objc private func addAccount() {
        accountNavigationTVC.addAccount()
    }

    private func addCurrencyTVC() {
        let tempCurrencyTVC = CurrencyViewController(delegate: self, mode: .setAccountingCurrency)
        currencyTVC = tempCurrencyTVC
        addChild(currencyTVC)

        mainView.addSubview(currencyTVC.view)
        currencyTVC.view.translatesAutoresizingMaskIntoConstraints = false
        currencyTVC.view.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        currencyTVC.view.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        currencyTVC.view.topAnchor.constraint(equalTo: addButton.bottomAnchor).isActive = true
        currencyTVC.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true

        currencyTVC.didMove(toParent: self)
    }

    private func addBankProfilesButton() {
        addBankProfileButton.addTarget(self, action: #selector(self.addBankProfileButtonDidTap), for: .touchUpInside)
        mainView.addSubview(addBankProfileButton)
        addBankProfileButton.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.9).isActive = true
        addBankProfileButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        addBankProfileButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        addBankProfileButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 40).isActive = true
    }

    private func removeBankProfilesButton() {
        addBankProfileButton.removeFromSuperview()
    }

    @objc private func addBankProfileButtonDidTap() {
        self.navigationController?.pushViewController(UserBankProfileTableViewController(), animated: true)
    }

    private func removeCurrencyTVC() {
        currencyTVC.delegate = nil
        currencyTVC.view.removeFromSuperview()
        currencyTVC.removeFromParent()
        currencyTVC = nil
    }

    private func addAccountNavigatorTVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        accountNavigationTVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.accountNavigatorTableVC) as AccountNavigatorTableViewController // swiftlint:disable:this line_length
        accountNavigationTVC.account = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), context: context) // swiftlint:disable:this line_length
        accountNavigationTVC.searchBarIsHidden = true
        addChild(accountNavigationTVC)
        mainView.addSubview(accountNavigationTVC.view)
        accountNavigationTVC.view.translatesAutoresizingMaskIntoConstraints = false
        accountNavigationTVC.view.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        accountNavigationTVC.view.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        accountNavigationTVC.view.topAnchor.constraint(equalTo: addButton.bottomAnchor).isActive = true
        accountNavigationTVC.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true

        accountNavigationTVC.didMove(toParent: self)
    }

    func configureUIForStep() {
        titleLabel.text = workFlowTitleArray[currentStep]
        accountNavigationTVC.resetPredicate()
        accountNavigationTVC.fetchData()
    }

    @objc private func nextStep() { // swiftlint:disable:this function_body_length cyclomatic_complexity
        if currentStep == 0 {
            if  let currency = currency {
                do {
                    SeedDataManager.addBaseAccounts(accountingCurrency: currency, context: context)

                    try coreDataStack.saveContext(context)

                    currentStep += 1
                    titleLabel.text = workFlowTitleArray[currentStep]
                    addButton.addTarget(self, action: #selector(self.addAccount), for: .touchUpInside)

                    removeCurrencyTVC()
                    addBankProfilesButton()
                } catch let error {
                    errorHandler(error: error)
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                              message: NSLocalizedString("Please choose currency", comment: ""),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        } else if currentStep == 1 {
            currentStep += 1
            addButton.alpha = 1
            removeBankProfilesButton()
            addAccountNavigatorTVC()
            configureUIForStep()
        } else if currentStep == 2 {
            currentStep += 1
            accountNavigationTVC.account = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), context: context) // swiftlint:disable:this line_length
            configureUIForStep()
        } else if currentStep == 3 {
            currentStep += 1
            accountNavigationTVC.account = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context) // swiftlint:disable:this line_length
            configureUIForStep()
        } else if currentStep == 4 {
            currentStep += 1
            accountNavigationTVC.account = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), context: context) // swiftlint:disable:this line_length
            configureUIForStep()
        } else if currentStep == 5 {
            currentStep += 1
            accountNavigationTVC.account = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.credits), context: context) // swiftlint:disable:this line_length
            configureUIForStep()
            nextButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else if currentStep == 6 {
            do {
                try context.save()
                NotificationCenter.default.post(name: .environmentDidChange, object: nil)
                UserProfile.firstAppLaunch()
                if let backToVC = backToVC {
                    self.navigationController?.popToViewController(backToVC, animated: true)
                } else {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController) // swiftlint:disable:this line_length
                    self.navigationController?.popToRootViewController(animated: false)

                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            } catch let error {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                              style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                      style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension StartAccountingViewController: CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency) {
        currency = selectedCurrency
    }
}
