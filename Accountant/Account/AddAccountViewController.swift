//
//  AddAccountViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit







//FIXME: - fix me
//FIXME: - fix me








class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    
    let coreDataStack : CoreDataStack = CoreDataStack.shared
    var currency : Currency!
    var pickerData : [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Create Account"
        //FIXME: -
//        guard let curr = coreDataStack.getAccountingCurrency() else {return}
//        currency = curr
//        pickerData = CurrencyEnum.MULTICURRENCY.getCurrencyList()
//        addButtonToViewController()
//        currencyTextField.text = currency.code
//        currencyTextField.setInputViewPickerView(target: self, data : pickerData, selector : #selector(done))
    }
    
    @objc func done() {
//        if self.currencyTextField.inputView as? UIPickerView != nil {
//            currencyTextField.text = pickerData[currencyTextField.selectedItemIndex]
//            currency = pickerData[currencyTextField.selectedItemIndex]
//        }
        self.currencyTextField.resignFirstResponder()
        
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
    //TODO: - fix this code
    @objc func save(_ sender:UIButton!){
//        var typeOfAccount : AccountType = .assets
//        if segmentedControl.selectedSegmentIndex == 1 {
//            typeOfAccount = .liabilities
//        }
//        do {
//            if let name = nameTextField.text, name != "" {
//                try coreDataStack.createAccount(parent: nil, name: name, type: typeOfAccount.rawValue, currency: currency)
//                navigationController?.popViewController(animated: true)
//            }
//        }
//        catch let error{
//            print("ERROR", error)
//
//            if error as? AccountError != nil {
//                let alert = UIAlertController(title: "Warning", message: "Account with this name already exists. Please try another name.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true, completion: nil)
//            }
//            else {
//                let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
