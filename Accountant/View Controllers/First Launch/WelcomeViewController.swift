//
//  WelcomeViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.09.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 30.0
        stackView.backgroundColor = UIColor(white: 1, alpha: 0)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = NSLocalizedString("Welcome", comment: "").uppercased()
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let startAccountingButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Start accounting", comment: "").uppercased(), for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let testButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Try functionality", comment: "").uppercased(), for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        
        //MARK: - Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        mainStackView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        mainStackView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        mainStackView.addArrangedSubview(titleLabel)
        
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        //MARK: - Start Accounting Button
        let widthBtn = CGFloat(UIScreen.main.bounds.width - 25 * 2)
        startAccountingButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        startAccountingButton.widthAnchor.constraint(equalToConstant: widthBtn).isActive = true
        
        startAccountingButton.layer.cornerRadius = Constants.Size.cornerButtonRadius
        
        let gradientPinkView = GradientView(frame: startAccountingButton.bounds, colorTop: .systemPink, colorBottom: .systemRed)
        gradientPinkView.layer.cornerRadius = Constants.Size.cornerButtonRadius
        
        startAccountingButton.insertSubview(gradientPinkView, at: 0)
        startAccountingButton.layer.masksToBounds = false;
        
        mainStackView.addArrangedSubview(startAccountingButton)
        gradientPinkView.addTarget(self, action: #selector(startAccounting), for: .touchUpInside)
        
        //MARK: - Start Accounting Button
        //        let widthBtn = CGFloat(UIScreen.main.bounds.width - 25 * 2)
        testButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        testButton.widthAnchor.constraint(equalToConstant: widthBtn).isActive = true
        testButton.layer.cornerRadius = Constants.Size.cornerButtonRadius
        
        let gradientOrangeView = GradientView(frame: testButton.bounds, colorTop: .systemOrange, colorBottom: .systemYellow)
        gradientOrangeView.layer.cornerRadius = Constants.Size.cornerButtonRadius
        
        testButton.insertSubview(gradientOrangeView, at: 0)
        testButton.layer.masksToBounds = false;
        
        mainStackView.addArrangedSubview(testButton)
        gradientOrangeView.addTarget(self, action: #selector(tryFunctionality), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        startAccountingButton.isUserInteractionEnabled = true
        testButton.isUserInteractionEnabled = true
    }
    
    @objc private func startAccounting(_ sender: UIButton) {
        startAccountingButton.isUserInteractionEnabled = false
        testButton.isUserInteractionEnabled = false
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.startAccountingViewController) as! StartAccountingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tryFunctionality(_ sender: UIButton) {
        startAccountingButton.isUserInteractionEnabled = false
        testButton.isUserInteractionEnabled = false
        
        CoreDataStack.shared.switchToDB(.test)
        
        do {
            let context = CoreDataStack.shared.persistentContainer.viewContext
            
            //remove old test Data
            let env = CoreDataStack.shared.activeEnviroment()
            try SeedDataManager.deleteAllTransactions(context: context, env:env)
            try SeedDataManager.deleteAllAccounts(context: context, env:env)
            try SeedDataManager.deleteAllCurrencies(context: context, env:env)
            try SeedDataManager.deleteAllKeepers(context: context, env:env)
            try SeedDataManager.deleteAllHolders(context: context, env:env)
            try SeedDataManager.deleteAllBankAccounts(context: context, env: env)
            try SeedDataManager.deleteAllUBP(context: context, env: env)
            try SeedDataManager.deleteAllRates(context: context, env: env)
            try SeedDataManager.deleteAllExchanges(context: context, env: env)
            try CoreDataStack.shared.saveContext(context)
            
            //add test Data
            SeedDataManager.addCurrencies(context: context)
            guard let currency = try Currency.getCurrencyForCode("UAH", context: context) else {return}
            try Currency.changeAccountingCurrency(old: nil, new: currency, context: context)
            try SeedDataManager.createTestKeepers(context: context)
            try SeedDataManager.createTestHolders(context: context)
            try SeedDataManager.addBaseAccountsTest(accountingCurrency: currency, context: context)
            try CoreDataStack.shared.saveContext(context)
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
            self.navigationController?.popToRootViewController(animated: false)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    func errorHandler(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
