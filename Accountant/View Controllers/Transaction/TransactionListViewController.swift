//
//  MainViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 04.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
//import GoogleMobileAds
import Purchases

class TransactionListViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var isUserHasPaidAccess: Bool = false
    
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    var environment = Environment.prod
    
    var resultSearchController = UISearchController()
    
    lazy var fetchedResultsController : NSFetchedResultsController<Transaction> = {
        let fetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false), NSSortDescriptor(key: "createDate", ascending: false)]
        
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    
//    private var interstitial: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButtonToViewController()
        
        //MARK:-Set black color under cells in dark mode
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = .systemBackground
        self.tableView.backgroundView = backView

        reloadProAccessData()
        
        tableView.register(ComplexTransactionTableViewCell.self, forCellReuseIdentifier: Constants.Cell.complexTransactionCell)
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange), name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
        
        //MARK:- TabBarController badge manage
        for (index,item) in (tabBarController?.tabBar.items as! [UITabBarItem]).enumerated() {
            guard index != (tabBarController?.tabBar.items as! [UITabBarItem]).count - 1 else {return}
            if coreDataStack.activeEnviroment() == .test {
                item.badgeValue = "Test"
            }
            else {
                item.badgeValue = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tabBarController?.navigationItem.title = NSLocalizedString("Transactions", comment: "")
        if isUserHasPaidAccess == false {
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Get PRO", comment: ""), style: .plain, target: self, action: #selector(self.showPurchaseOfferVC))
        }
        
        fetchData()
        
        if isUserHasPaidAccess == false {
            createAd()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        resultSearchController.dismiss(animated: true, completion: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }
    
    func createAd() {
//        let request = GADRequest()
//        GADInterstitialAd.load(withAdUnitID:Constants.APIKey.googleAD,
//                               request: request,
//                               completionHandler: { [self] ad, error in
//                                if let error = error {
//                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                                    return
//                                }
//                                interstitial = ad
//                               })
    }
    
    @objc func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch {
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func addTransaction(_ sender:UIButton!){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if UserProfile.isUseMultiItemTransaction(environment: environment) {
            let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorViewController) as! ComplexTransactionEditorViewController
            
            transactioEditorVC.context = context
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        }
        else {
            let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.simpleTransactionEditorViewController) as! SimpleTransactionEditorViewController
            //        transactioEditorVC.interstitial = interstitial
            transactioEditorVC.isUserHasPaidAccess = isUserHasPaidAccess
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        }
    }
    
    
    @objc func environmentDidChange(){
        
        //MARK:- reset context and fetchedResultsController
        context = CoreDataStack.shared.persistentContainer.viewContext
        if let environment = coreDataStack.activeEnviroment() {
            self.environment = environment
        }
        fetchedResultsController = {
            let fetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: "Transaction")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            fetchRequest.fetchBatchSize = 20
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            return frc
        }()
        
        //MARK:- clear resultSearchController
        resultSearchController.searchBar.text = ""
        
        //MARK:- TabBarController badge manage
        for (index,item) in (tabBarController?.tabBar.items as! [UITabBarItem]).enumerated() {
            guard index != (tabBarController?.tabBar.items as! [UITabBarItem]).count - 1 else {return}
            if coreDataStack.activeEnviroment() == .test {
                item.badgeValue = "Test"
            }
            else {
                item.badgeValue = nil
            }
        }
    }
    
    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            }
            else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
                UserProfile.useMultiItemTransaction(false, environment: self.environment)
            }
        }
    }
    
    
    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        addButton.backgroundColor = .systemGray5
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        let standardSpacing: CGFloat = -40.0
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(89-49)), //49- tabbar heigth
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: standardSpacing),
            addButton.heightAnchor.constraint(equalToConstant: 68),
            addButton.widthAnchor.constraint(equalToConstant: 68)
        ])
        
        addButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "plus") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(TransactionListViewController.addTransaction(_:)), for: .touchUpInside)
    }
}



extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.complexTransactionCell, for: indexPath) as! ComplexTransactionTableViewCell
        let transaction  = fetchedResultsController.object(at: indexPath) as Transaction
        cell.setTransaction(transaction)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = fetchedResultsController.object(at: indexPath) as Transaction
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      
        if (transaction.items?.allObjects as! [TransactionItem]).count > 2 ||  UserProfile.isUseMultiItemTransaction(environment: environment) {
            let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorViewController) as! ComplexTransactionEditorViewController
            transactioEditorVC.transaction = transaction
            transactioEditorVC.context = context
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        }
        else {
            let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.simpleTransactionEditorViewController) as! SimpleTransactionEditorViewController
            transactioEditorVC.transaction = transaction
            //        transactioEditorVC.interstitial = interstitial
            transactioEditorVC.isUserHasPaidAccess = isUserHasPaidAccess
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: NSLocalizedString("Delete",comment: "")) { (contAct, view, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Delete", comment: ""), message: NSLocalizedString("Do you want to delete transaction?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: {(_) in
                
                TransactionManager.deleteTransaction(self.fetchedResultsController.object(at: indexPath) as Transaction, context: self.context)
                do {
                    try self.fetchedResultsController.performFetch()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch {
                    let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        
        let duplicate = UIContextualAction(style: .normal, title: NSLocalizedString("Duplicate",comment: "")) { _, _, complete in
            do {
                if self.isUserHasPaidAccess || self.coreDataStack.activeEnviroment() == .test {
                    let transaction = self.fetchedResultsController.object(at: indexPath) as Transaction
                    TransactionManager.copyTransaction(transaction, context: self.context)
                    try self.coreDataStack.saveContext(self.context)
                    try self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                }
                else  {
                    self.showPurchaseOfferVC()
                }
            }
            catch {
                let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            complete(true)
        }
        
        let configuration : UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: [delete,duplicate])
        configuration?.actions[0].backgroundColor = .systemRed
        configuration?.actions[0].image = UIImage(systemName: "trash")
        configuration?.actions[1].backgroundColor = .systemBlue
        configuration?.actions[1].image = UIImage(systemName: "doc.on.doc")
        return configuration
    }
    
    
}

extension TransactionListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count != 0 {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "items.account.path CONTAINS[c] %@ || comment CONTAINS[c] %@", argumentArray: [searchController.searchBar.text!, searchController.searchBar.text!])
        }
        else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        
        fetchData()
    }
}
