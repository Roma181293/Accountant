//
//  StartAccountingViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.09.2021.
//

import UIKit

class StartAccountingViewController: UIViewController {

    weak var parentVC: UIViewController?

    private var coreDataStack = CoreDataStack.shared
    private var context = CoreDataStack.shared.persistentContainer.viewContext
    private(set) var currentStep = 0
    private var currency: Currency?
    private unowned var currencyListVC: CurrencyViewController!
    private var accountNavigationTVC: AccountNavigationViewController!

    // swiftlint:disable line_length
    var workFlowTitleArray = [
        NSLocalizedString("Choose currecy for Income and Expenses categories. This currency cannot be changed in the future",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: ""),
        NSLocalizedString("Add Monobank bank profile, to sync statements data. All the data stores only on this device locally",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: ""),
        NSLocalizedString("Please add income categories.\nBy tapping ⊕ button, or add subcategories by swiping from right to left. If you tap to the category that has \">\" you can see all subcategories to the selected one",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: ""),
        NSLocalizedString("Please add expense categories",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: ""),
        NSLocalizedString("Please add money accounts (Cash and bank cards). \nDo NOT enter secure info about bank cards(full card number and CV2 code)",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: ""),
        NSLocalizedString("Please add debtors. Debtors also include bank deposits",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: ""),
        NSLocalizedString("Please add credits. Credit card limits are automatically added to credits",
                          tableName: Constants.Localizable.startAccountingVC,
                          comment: "")]
    // swiftlint:enable line_length

    private lazy var mainView: StartAccountingView = {return StartAccountingView(controller: self)}()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Accounting start",
                                                      tableName: Constants.Localizable.startAccountingVC,
                                                      comment: "")
        addMininalDictionariesData()
        addCurrencyListVC()
        mainView.continueButton.addTarget(self, action: #selector(self.nextStep), for: .touchUpInside)
    }

    // TODO: - investigate can be deleted `parentVC != nil &&`
    deinit {
        if parentVC != nil && UserProfileService.isAppLaunchedBefore() == false {
            CoreDataStack.shared.switchPersistentStore(.test)
            NotificationCenter.default.post(name: .environmentDidChange, object: nil)
        }
    }

    @objc private func addAccount() {
        accountNavigationTVC.addCategoryOrAccount()
    }

    private func addMininalDictionariesData() {
        CoreDataStack.shared.switchPersistentStore(.prod)
        context = CoreDataStack.shared.persistentContainer.viewContext
        do {
            if UserProfileService.isAppLaunchedBefore() == false {
                try coreDataStack.restorePersistentStore(.prod)
            }

            context = CoreDataStack.shared.persistentContainer.viewContext
            // add New Data
            try SeedDataService.addProdData(persistentContainer: CoreDataStack.shared.persistentContainer)
        } catch let error {
            errorHandler(error: error)
        }
    }

    private func addCurrencyListVC() {
        let tempCurrencyListVC = CurrencyViewController()
        tempCurrencyListVC.delegate = self
        tempCurrencyListVC.mode = .setAccountingCurrency
        currencyListVC = tempCurrencyListVC
        addChild(currencyListVC)
        mainView.addContentView(currencyListVC.view)
        currencyListVC.didMove(toParent: self)
    }

    private func addBankProfilesButton() {
        mainView.goToBankProfilesButton.addTarget(self,
                                                  action: #selector(self.addBankProfileButtonDidTap),
                                                  for: .touchUpInside)
        mainView.addGoToBankProfilesButton()
    }

    @objc private func addBankProfileButtonDidTap() {
        self.navigationController?.pushViewController(UserBankProfileListViewController(), animated: true)
    }

    private func removeCurrencyListVC() {
        currencyListVC.delegate = nil
        currencyListVC.view.removeFromSuperview()
        currencyListVC.removeFromParent()
        currencyListVC = nil
    }

    private func addAccountNavigationVC() {
        accountNavigationTVC = AccountNavigationViewController()
        accountNavigationTVC.parentAccount = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.income), context: context) // swiftlint:disable:this line_length
        accountNavigationTVC.searchBarIsHidden = true
        addChild(accountNavigationTVC)
        mainView.addContentView(accountNavigationTVC.view)
        accountNavigationTVC.didMove(toParent: self)
    }

    func configureUIForStep() {
        mainView.updateForCurrentStep()
        accountNavigationTVC.resetPredicate()
    }

    @objc func nextStep() { // swiftlint:disable:this function_body_length cyclomatic_complexity
        if currentStep == 0 {
            guard let currency = currency else {return}
            do {
                SeedDataService.addBaseAccounts(accountingCurrency: currency, context: context)
                try coreDataStack.saveContext(context)
            } catch let error {
                errorHandler(error: error)
            }
            currentStep += 1
            mainView.updateForCurrentStep()
            mainView.addButton.addTarget(self, action: #selector(self.addAccount), for: .touchUpInside)
            removeCurrencyListVC()
            addBankProfilesButton()
        } else if currentStep == 1 {
            currentStep += 1
            mainView.addButton.alpha = 1
            mainView.removeGoToBankProfilesButton()
            addAccountNavigationVC()
            configureUIForStep()
        } else if currentStep == 2 {
            currentStep += 1
            accountNavigationTVC.parentAccount = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.expense), context: context) // swiftlint:disable:this line_length
            accountNavigationTVC.refreshDataForNewParent()
            configureUIForStep()
        } else if currentStep == 3 {
            currentStep += 1
            accountNavigationTVC.parentAccount = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.money), context: context) // swiftlint:disable:this line_length
            accountNavigationTVC.refreshDataForNewParent()
            configureUIForStep()
        } else if currentStep == 4 {
            currentStep += 1
            accountNavigationTVC.parentAccount = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.debtors), context: context) // swiftlint:disable:this line_length
            accountNavigationTVC.refreshDataForNewParent()
            configureUIForStep()
        } else if currentStep == 5 {
            currentStep += 1
            accountNavigationTVC.parentAccount = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.credits), context: context) // swiftlint:disable:this line_length
            accountNavigationTVC.refreshDataForNewParent()
            configureUIForStep()
            mainView.continueButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else if currentStep == 6 {
            do {
                try context.save()
                NotificationCenter.default.post(name: .environmentDidChange, object: nil)
                UserProfileService.firstAppLaunch()
                if let parentVC = parentVC {
                    self.navigationController?.popToViewController(parentVC, animated: true)
                } else {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController) // swiftlint:disable:this line_length
                    self.navigationController?.popToRootViewController(animated: false)

                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            } catch let error {
                errorHandler(error: error)
            }
        }
    }

    private func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error",
                                                               tableName: Constants.Localizable.startAccountingVC,
                                                               comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.startAccountingVC,
                                                               comment: ""),
                                      style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension StartAccountingViewController: CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency) {
        currency = selectedCurrency
        mainView.continueButton.isHidden = false
    }
}
