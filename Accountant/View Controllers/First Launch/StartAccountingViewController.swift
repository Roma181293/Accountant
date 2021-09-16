//
//  StartAccountingViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.09.2021.
//

import UIKit

class StartAccountingViewController: UIViewController, CurrencyReceiverDelegate {
    
    var coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var currencyTVC: CurrencyTableViewController!
    var accountNavigationTVC: AccountNavigatorTableViewController!
    var vc: UIViewController?
    
    var currentStep = 0
    var currency: Currency?
    
    var workFlowTitleArray = [
        NSLocalizedString("Please choose accounting start date. When you adding existing account, this date will be using automatically", comment: ""),
        NSLocalizedString("Choose currecy for Income and Expense categories(accounts). This currency cannot be changed in the future", comment: ""),
        NSLocalizedString("Please add Income categories(accounts)", comment: ""),
        NSLocalizedString("Please add Expense categories(accounts)", comment: ""),
        NSLocalizedString("Please add Money accounts (Cash and bank cards)", comment: ""),
        NSLocalizedString("Please add debtors. Debtors also include deposits", comment: ""),
        NSLocalizedString("Please add credits. Credit limit on card credit are automatically added to the credits", comment: "")]
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cardView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Size.cornerCardRadius
        view.layer.backgroundColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
       
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let addButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.Main.confirmButton
        button.setImage(UIImage(systemName: "arrow.right") , for: .normal)
        button.layer.cornerRadius = 34
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Accounting start", comment: "")
        
        CoreDataStack.shared.switchToDB(.prod)
      
        context = CoreDataStack.shared.persistentContainer.viewContext
        
        //remove Old Data
        if UserProfile.isAppLaunchedBefore() == false {
            do {
                try TransactionManager.deleteAllTransactions(context: context)
                try AccountManager.deleteAllAccounts(context: context)
                try CurrencyManager.deleteAllCurrencies(context: context)
                try CoreDataStack.shared.saveContext(context)
            }
            catch let error {
                errorHandler(error: error)
            }
        }
        
        //add New Data
        CurrencyManager.addCurrencies(context: context)
        
        addMainView()
        
        titleLabel.text = workFlowTitleArray[currentStep]
        nextButton.addTarget(self, action: #selector(self.nextStep), for: .touchUpInside)
    }
    
    deinit {
        if vc != nil && UserProfile.isAppLaunchedBefore() == false {
            CoreDataStack.shared.switchToDB(.test)
            NotificationCenter.default.post(name: .environmentDidChange, object: nil)
        }
    }
    
    private func addMainView() {
        //MARK: - Main view
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //MARK: - Card View
        mainView.addSubview(cardView)
        cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8).isActive = true
        cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8).isActive = true
        cardView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        
        //MARK: - Title Label
        cardView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        //MARK: - Add Button
        mainView.addSubview(addButton)
        addButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        //MARK: - Date Picker
        mainView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 80).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        
        //MARK: - Next button
        view.addSubview(nextButton)
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }
    
    func setCurrency(_ selectedCurrency: Currency) {
        currency = selectedCurrency
    }
    
    @objc private func addAccount() {
        accountNavigationTVC.addAccount()
    }
    
    private func addCurrencyTVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        currencyTVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.currencyTableViewController)
            as CurrencyTableViewController
        currencyTVC.delegate = self
        currencyTVC.context = CoreDataStack.shared.persistentContainer.viewContext
        currencyTVC.mode = .setAccountingCurrency
        
        addChild(currencyTVC)
        
        mainView.addSubview(currencyTVC.view)
        currencyTVC.view.translatesAutoresizingMaskIntoConstraints = false
        currencyTVC.view.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        currencyTVC.view.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        currencyTVC.view.topAnchor.constraint(equalTo: addButton.bottomAnchor).isActive = true
        currencyTVC.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
        currencyTVC.didMove(toParent: self)
    }
    
    private func removeCurrencyTVC(){
        currencyTVC.delegate = nil
        currencyTVC.view.removeFromSuperview()
        currencyTVC.removeFromParent()
        currencyTVC = nil
    }
    
    private func addAccountNavigatorTVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        accountNavigationTVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.accountNavigatorTableViewController) as AccountNavigatorTableViewController
        
        accountNavigationTVC.account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), context: context)
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
    
    @objc private func nextStep(){
        if currentStep == 0 {
            currentStep += 1
            let calendar = Calendar.current
            guard let date = calendar.dateInterval(of: .day, for: datePicker.date)?.start else {return}
            UserProfile.setAccountingStartDate(date)
          
            
            datePicker.isHidden = true
            datePicker.removeFromSuperview()
            
            titleLabel.text = workFlowTitleArray[currentStep]
            
            addCurrencyTVC()
            
        }
        else if currentStep == 1 {
            if  let currency = currency {
                do {
                    AccountManager.addBaseAccounts(accountingCurrency: currency, context: context)
                    
                    try coreDataStack.saveContext(context)
                    
                    currentStep += 1
                    titleLabel.text = workFlowTitleArray[currentStep]
                    addButton.alpha = 1
                    addButton.addTarget(self, action: #selector(self.addAccount), for: .touchUpInside)
                    
                    removeCurrencyTVC()
                    addAccountNavigatorTVC()
                }
                catch let error {
                    errorHandler(error: error)
                }
            }
            else {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message:  NSLocalizedString("Please choose currency", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if currentStep == 2 {
            currentStep += 1
            accountNavigationTVC.account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), context: context)
            configureUIForStep()
        }
        else if currentStep == 3 {
            currentStep += 1
            accountNavigationTVC.account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
            configureUIForStep()
        }
        else if currentStep == 4 {
            currentStep += 1
            accountNavigationTVC.account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), context: context)
            configureUIForStep()
        }
        else if currentStep == 5 {
            currentStep += 1
            accountNavigationTVC.account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.credits), context: context)
            configureUIForStep()
            nextButton.setImage(UIImage(systemName: "checkmark") , for: .normal)
            
        }
        else if currentStep == 6 {
            do{
                try context.save()
                NotificationCenter.default.post(name: .environmentDidChange, object: nil)
                UserProfile.firstAppLaunch()
                if let vc = vc {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                else {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
                    self.navigationController?.popToRootViewController(animated: false)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
                }
            }
            catch let error{
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
