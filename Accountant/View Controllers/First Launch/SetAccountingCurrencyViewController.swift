//
//  setAccountingCurrencyViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 04.08.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData

class SetAccountingCurrencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    var accountingCurrency: Currency?{
        didSet{
            addButtonToViewController()
        }
    }
    var accountingCurrencyIndexPath: IndexPath?
    
    lazy var fetchedResultsController : NSFetchedResultsController<Currency> = {
        let fetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: "Currency")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrencyManager.addCurrencies(context: context)
        do {
            try coreDataStack.saveContext(context)
        }
        catch let error {
            print("Error",error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationItem.title = NSLocalizedString("Accounting currency", comment: "")
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch let error{
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.setAccountingCurrencyCell, for: indexPath) as! CurrencyTableViewCell
        let currency = fetchedResultsController.object(at: indexPath) as Currency
        if currency.isAccounting {
            accountingCurrency = currency
            accountingCurrencyIndexPath = indexPath
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        cell.codeLabel.text = currency.code!
        if let name = currency.name  {
            cell.nameLabel.text = name
        }
        else {
            cell.nameLabel.text = NSLocalizedString(currency.code!, comment: "")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        do {
        let currency = fetchedResultsController.object(at: indexPath) as Currency
        guard let accountingCurrencyIndexPath = accountingCurrencyIndexPath else {
            try CurrencyManager.changeAccountingCurrency(old: nil, new: currency, context: context)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        if indexPath != accountingCurrencyIndexPath {
            try CurrencyManager.changeAccountingCurrency(old: accountingCurrency, new: currency, context: context)
        }
        tableView.reloadRows(at: [accountingCurrencyIndexPath,indexPath], with: .automatic)
        }
        catch let error{
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        addButton.backgroundColor = .systemGray5
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            addButton.heightAnchor.constraint(equalToConstant: 68),
            addButton.widthAnchor.constraint(equalToConstant: 68),
          ])
        
        addButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "arrow.right") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(SetAccountingCurrencyViewController.next(_:)), for: .touchUpInside)
    }
    
    @objc func next(_ sender:UIButton!) {
        do{
            guard let accountingCurrency = accountingCurrency else {return}
            
            AccountManager.addBaseAccounts(accountingCurrency: accountingCurrency, context: context)
            try coreDataStack.saveContext(context)
            UserProfile.firstAppLaunch()
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
            self.navigationController?.popToRootViewController(animated: false)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = UINavigationController(rootViewController: tabBar)
        }
        catch let error{
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
