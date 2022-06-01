//
//  AddAccountViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class RootAccountEditorViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!

    var isUserHasPaidAccess: Bool = false
    var environment: Environment = .prod

    let coreDataStack: CoreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var currency: Currency?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Create account", comment: "")
        configureUI()
        nameTextField.delegate = self
        nameTextField.tag = 100
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func configureUI() { // swiftlint:disable:this function_body_length
        currencyButton.backgroundColor = Colors.Main.defaultButton
        currencyButton.layer.cornerRadius = Constants.Size.cornerButtonRadius
        refreshButton.backgroundColor = Colors.Main.defaultButton
        refreshButton.layer.cornerRadius = Constants.Size.cornerButtonRadius
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 ,
                                                               y: self.view.frame.height - 150),
                                               size: CGSize(width: 50, height: 50)))
        addButton.backgroundColor = Colors.Main.confirmButton
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: addButton,
                                                      attribute: NSLayoutConstraint.Attribute.trailing,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: view,
                                                      attribute: NSLayoutConstraint.Attribute.trailing,
                                                      multiplier: 1,
                                                      constant: -40)
        var constant: CGFloat = 40
        if let tabBarController = self.tabBarController {
            constant += tabBarController.tabBar.frame.size.height
        }
        let verticalConstraint = NSLayoutConstraint(item: addButton,
                                                    attribute: NSLayoutConstraint.Attribute.bottom,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: view,
                                                    attribute: NSLayoutConstraint.Attribute.bottom,
                                                    multiplier: 1,
                                                    constant: -constant)
        let widthConstraint = NSLayoutConstraint(item: addButton,
                                                 attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 68)
        let heightConstraint = NSLayoutConstraint(item: addButton,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 68)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])

        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = Colors.Main.confirmButton
        addButton.layer.cornerRadius = 34
        addButton.layer.shadowColor = UIColor.gray.cgColor
        addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowRadius = 3
        addButton.layer.masksToBounds =  false
        addButton.addTarget(self, action: #selector(RootAccountEditorViewController.save(_:)), for: .touchUpInside)
    }

    @IBAction func selectCurrency(_ sender: UIButton) {
        let currencyVC = CurrencyViewController(currency: currency, delegate: self, mode: .setCurrency)
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }

    @IBAction func refreshCurrency(_ sender: UIButton) {
        currency = nil
        currencyButton.setTitle(NSLocalizedString("Multicurrency", comment: ""), for: .normal)
    }

    @objc func save(_ sender: UIButton!) {
//        var typeOfAccount: Account.TypeEnum = .assets
//        if segmentedControl.selectedSegmentIndex == 1 {
//            typeOfAccount = .liabilities
//        }
//        do {
//            if let name = nameTextField.text, name != "" {
//                try Account.createAccount(parent: nil,
//                                          name: name,
//                                          type: typeOfAccount,
//                                          currency: currency,
//                                          createdByUser: true,
//                                          context: context)
//                try context.save()
//                navigationController?.popViewController(animated: true)
//            }
//        } catch let error {
//            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
//                                          message: "\(error.localizedDescription)",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
//                                          style: .default))
//            self.present(alert, animated: true, completion: nil)
//        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RootAccountEditorViewController: CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency) {
        self.currency = selectedCurrency
        currencyButton.setTitle(selectedCurrency.code, for: .normal)
    }
}
