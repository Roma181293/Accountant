//
//  AddAccountViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    
    let coreDataStack : CoreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var currency : Currency?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Create Account"
        addButtonToViewController()
    }
    
    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 50, height: 50)))
        addButton.backgroundColor = .lightGray
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
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
        addButton.addTarget(self, action: #selector(AddAccountViewController.save(_:)), for: .touchUpInside)
    }
    
    @IBAction func selectCurrency(_ sender: UIButton){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let currencyTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableViewController) as! CurrencyTableViewController
        currencyTableViewController.delegate = self
        currencyTableViewController.currency = currency
        self.navigationController?.pushViewController(currencyTableViewController, animated: true)
    }
    
    @IBAction func refreshCurrency(_ sender: UIButton){
        currency = nil
        currencyButton.setTitle("Multicurrency", for: .normal)
    }
    
    @objc func save(_ sender:UIButton!){
        var typeOfAccount : AccountType = .assets
        if segmentedControl.selectedSegmentIndex == 1 {
            typeOfAccount = .liabilities
        }
        do {
            if let name = nameTextField.text, name != "" {
                try AccountManager.createAccount(parent: nil, name: name, type: typeOfAccount.rawValue, currency: currency, context: context)
                try context.save()
                navigationController?.popViewController(animated: true)
            }
        }
        catch let error{
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
        }
    }
}


extension AddAccountViewController: CurrencyReceiverDelegate{
    func setCurrency(_ selectedCurrency: Currency) {
        self.currency = selectedCurrency
        currencyButton.setTitle(selectedCurrency.code!, for: .normal)
    }
}
