//
//  MainViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 04.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class TransactionListViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    private var interstitial: GADInterstitialAd?
    
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    let coreDataStack = CoreDataStack.shared
    var resultSearchController = UISearchController()
    
    lazy var fetchedResultsController : NSFetchedResultsController<Transaction> = {
        let fetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonToViewController()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Transactions", comment: "")
        
        fetchData()

        if let entitlement = UserProfile.getEntitlement(),
           (entitlement.name != .pro || (entitlement.name != .pro && entitlement.expirationDate! < Date())) {
            createAd()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        resultSearchController.dismiss(animated: true, completion: nil)
    }
    
    func createAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitial = ad
                               })
    }
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch {
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok",comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func addTransaction(_ sender:UIButton!){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.transactionEditorViewController) as! TransactionEditorViewController
        transactionEditorVC.interstitial = interstitial
        self.navigationController?.pushViewController(transactionEditorVC, animated: true)
    }
    
    
    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        addButton.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.transactionCell, for: indexPath) as! TransactionTableViewCell
        let transaction  = fetchedResultsController.object(at: indexPath) as Transaction
        cell.updateCell(transaction: transaction)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.transactionEditorViewController) as! TransactionEditorViewController
        transactioEditorVC.transaction = fetchedResultsController.object(at: indexPath) as Transaction
        transactioEditorVC.interstitial = interstitial
        self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: NSLocalizedString("Delete",comment: "")) { (contAct, view, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Delete transaction", comment: ""), message: NSLocalizedString("Do you really want delete transaction?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: {(_) in
                
                TransactionManager.deleteTransaction(self.fetchedResultsController.object(at: indexPath) as Transaction, context: self.context)
                do {
                    try self.fetchedResultsController.performFetch()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch {
                    let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok",comment: ""), style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        
        let copy = UIContextualAction(style: .normal, title: NSLocalizedString("Copy",comment: "")) { _, _, complete in
            do {
                guard let entitlement = UserProfile.getEntitlement(), let expirationDate = entitlement.expirationDate, expirationDate > Date() else {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    return}
                
                let transaction = self.fetchedResultsController.object(at: indexPath) as Transaction
                TransactionManager.copyTransaction(transaction, context: self.context)
                try self.coreDataStack.saveContext(self.context)
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok",comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            complete(true)
        }
        
        let configuration : UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: [delete,copy])
        configuration?.actions[0].backgroundColor = .systemRed
        configuration?.actions[1].backgroundColor = .systemGreen
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
