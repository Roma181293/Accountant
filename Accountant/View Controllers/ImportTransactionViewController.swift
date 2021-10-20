//
//  ImportTransactionTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 24.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class ImportTransactionViewController: UIViewController{
    
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    var dataFromFile: String = ""
    private var preTransactionList : [PreTransaction] = []
    private var showOlnyErrors: Bool = false
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let showOnlyErrorsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Show olny errors", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let showOnlyErrorsSwich: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 34
        button.backgroundColor = .systemGray5
        if let image = UIImage(systemName: "checkmark") {
            button.setImage(image, for: .normal)
        }
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //MARK:- Confirm button
        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.addTarget(self, action: #selector(ImportTransactionViewController.save), for: .touchUpInside)
        
        //MARK:- Stack View
        mainView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor,constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor,constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: mainView.topAnchor,constant: 8).isActive = true
        
        stackView.addArrangedSubview(showOnlyErrorsLabel)
        stackView.addArrangedSubview(showOnlyErrorsSwich)
        showOnlyErrorsSwich.addTarget(self, action: #selector(switching(_:)), for: .valueChanged)
        
        //MARK:- TableView
        mainView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8).isActive = true
        tableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
        //MARK:- Configure TableView
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PreTransactionTableViewCell.self, forCellReuseIdentifier: Constants.Cell.preTransactionTableViewCell)
        tableView.keyboardDismissMode = .onDrag;
        
        do{
            preTransactionList = try TransactionManager.importTransactionList(from: dataFromFile, context: context)
        }
        catch let error {
            errorHandler(error: error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NSLocalizedString("Import transactions", comment: "")
        
        isReadyToSave()
        tableView.reloadData()
    }
    
    
    deinit {
        context.rollback()
    }
    
    @objc func switching(_ sender: UISwitch) {
        showOlnyErrors = sender.isOn
        tableView.reloadData()
    }
    
    private func isReadyToSave() -> Bool {
        for item in preTransactionList {
            if item.isReadyToSave == false {
                print("Isn't ready")
                showOnlyErrorsLabel.isHidden = false
                showOnlyErrorsSwich.isHidden = false
                confirmButton.isHidden = true
                return false
            }
        }
        print("Ready")
        confirmButton.isHidden = false
        showOlnyErrors = false
        showOnlyErrorsLabel.isHidden = true
        showOnlyErrorsSwich.isHidden = true
        return true
    }
    
    @objc func save(){
        do {
            if isReadyToSave() {
                try coreDataStack.saveContext(context)
                let alert = UIAlertController(title: NSLocalizedString("Success",comment: ""), message: NSLocalizedString("All transactions successfully added",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default, handler: {(_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                try coreDataStack.saveContext(context)
                let alert = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message: NSLocalizedString("Please fix all errors in transaction list",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    func errorHandler(error: Error) {
        var title = NSLocalizedString("Error", comment: "")
        if error is AppError{
            title = NSLocalizedString("Warning", comment: "")
        }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ImportTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return preTransactionList.filter({if showOlnyErrors && $0.isReadyToSave {return false} else {return true}}).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.preTransactionTableViewCell, for: indexPath) as! PreTransactionTableViewCell
        cell.setTransaction(preTransactionList.filter({if showOlnyErrors && $0.isReadyToSave {return false} else {return true}})[indexPath.row].transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorViewController) as! ComplexTransactionEditorViewController
        transactioEditorVC.transaction = preTransactionList.filter({if showOlnyErrors && $0.isReadyToSave {return false} else {return true}})[indexPath.row].transaction
        transactioEditorVC.context = context
        transactioEditorVC.mode = .importMode
        self.navigationController?.pushViewController(transactioEditorVC, animated: true)
    }
}
