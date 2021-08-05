//
//  ImportTransactionTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 24.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class ImportTransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var addButton : UIButton!
    var dataFromFile: String = ""
    var preTransactionList : [PreTransaction] = []
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var isReadyToImport : Bool {
        for item in preTransactionList {
            if item.isReadyToCreateTransaction == false {
                print("Isn't ready")
                item.printPreTransaction()
                addButton.isHidden = true
                return false
            }
        }
        print("Ready")
        addButton.isHidden = false
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonToViewController()
        tableView.keyboardDismissMode = .onDrag;
        do{
            preTransactionList = try TransactionManager.importTransactionList(from: dataFromFile, context: context)
        }
        catch let error {
            print("Error", error)
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return preTransactionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.preTransactionTableViewCell, for: indexPath) as! PreTransactionTableViewCell
        cell.configureCell(preTransaction: preTransactionList[indexPath.row], tableView: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            preTransactionList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func addButtonToViewController() {
        addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 170 , y: self.view.frame.height - 150), size: CGSize(width: 50, height: 50)))
        addButton.backgroundColor = .lightGray
        addButton.tag = 1111
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        guard let addButton = addButton else {return}
        let horizontalConstraint = NSLayoutConstraint(item: addButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -40)
        
        var constant : CGFloat = 40
        if let tabBarController = self.tabBarController {
            constant += tabBarController.tabBar.frame.size.height
        }
        
        let verticalConstraint = NSLayoutConstraint(item: addButton, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy:
            NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -constant)
        let widthConstraint = NSLayoutConstraint(item: addButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 68)
        let heightConstraint = NSLayoutConstraint(item: addButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 68)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        addButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "plus") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(ImportTransactionViewController.importTransaction), for: .touchUpInside)
    }
    
    @objc func importTransaction(){
        do {
            TransactionManager.addTransactionsFromPreTransactionList(preTransactionList, context: context)
            try coreDataStack.saveContext(context)
            let alert = UIAlertController(title: NSLocalizedString("Success",comment: ""), message: NSLocalizedString("Transactions succesfully loaded",comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .cancel, handler: {(_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        catch let error {
            
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .cancel, handler: {(_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
