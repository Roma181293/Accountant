//
//  StartAccountingStepsViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 11.09.2021.
//

import UIKit
import CoreData

class StartAccountingStepsViewController: UIViewController {
    
    var coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var sourceList: [(account: Account, done: Bool)] = []
    
    var vc: UIViewController?
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = NSLocalizedString("Lets create accounts that you will be use in future", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.Main.confirmButton
        if let image = UIImage(systemName: "checkmark") {
            button.setImage(image, for: .normal)
        }
        button.layer.cornerRadius = 34
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(StepTableViewCell.self, forCellReuseIdentifier: Constants.Cell.stepItemCell)
        
        
        for item in  [BaseAccounts.expense, BaseAccounts.income, BaseAccounts.money ,BaseAccounts.debtors, BaseAccounts.credits] {
            sourceList.append((AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(item), context: context)!, false))
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        mainView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        
        mainView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
  
        
        view.addSubview(nextButton)
        
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        
        nextButton.addTarget(self, action: #selector(self.finish), for: .touchUpInside)
        
    }
    
    @objc func finish(){
        do{
            NotificationCenter.default.post(name: .environmentDidChange, object: nil)
            try context.save()
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

extension StartAccountingStepsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sourceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.stepItemCell, for: indexPath) as! StepTableViewCell
        cell.configureCell(sourceList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sourceList[indexPath.row].done = !sourceList[indexPath.row].done
        tableView.reloadRows(at: [indexPath], with: .automatic)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
        vc.account = sourceList[indexPath.row].account
        vc.showHiddenAccounts = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
