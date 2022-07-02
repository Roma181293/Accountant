//
//  TransactionListInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import Purchases
import CoreData

class TransactionListInteractor {

    weak var output: TransactionListInteractorOutput?
    private var isUserHasPaidAccess: Bool = false
    private let coreDataStack = CoreDataStack.shared
    private var environment = Environment.prod
    private var worker: TransactionListWorker

    init(worker: TransactionListWorker) {

        self.environment = coreDataStack.persistentContainer.environment
        self.worker = worker
        
        self.worker.provideData()

        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    @objc private func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
                UserProfile.useMultiItemTransaction(false, environment: self.environment)
            }
        }
    }

    @objc private func environmentDidChange() {
        self.environment = coreDataStack.persistentContainer.environment
        worker.changePersistentContainer(coreDataStack.persistentContainer)
        worker.provideData()
        output?.environmentDidChange(environment: self.environment)
    }
}

// MARK: - TransactionListInteractorInput
extension TransactionListInteractor: TransactionListInteractorInput {

    func hasActiveBankAccounts() -> Bool {
        return BankAccountHelper.hasActiveBankAccounts(context: coreDataStack.persistentContainer.viewContext)
    }

    func activeEnvironment() -> Environment {
        return environment
    }

    func activeContext() -> NSManagedObjectContext {
        return worker.context
    }

    func userHasPaidAccess() -> Bool {
        return isUserHasPaidAccess
    }

    func isMITransactionModeOn() -> Bool {
        return UserProfile.isUseMultiItemTransaction(environment: environment)
    }

    func loadStatmentsData() {
        let backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        StatementsLoadingService.loadStatments(context: backgroundContext,
                                               compliting: {(_, error) in
            if let error = error {
                self.output?.showError(error: error)
            }
        })
    }

    func canDuplicateTransaction() -> Bool {
        return isUserHasPaidAccess || coreDataStack.activeEnviroment() == .test
    }

    func duplicateTransaction(at indexPath: IndexPath) {
        worker.duplicateTransaction(at: indexPath)
    }

    func deleteTransaction(at indexPath: IndexPath) {
        worker.deleteTransaction(at: indexPath)
    }

    func search(text: String) {
        worker.search(text: text)
    }

    func numberOfSections() -> Int {
       return worker.numberOfSections()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return worker.numberOfRowsInSection(section)
    }

    func transactionAt(_ indexPath: IndexPath) -> TransactionViewModel {
        return worker.transactionAt(indexPath)
    }
}

// MARK: - TransactionListProviderDelegate
extension TransactionListInteractor: TransactionListWorkerDelegate {
    func didFetchTransactions() {
        output?.didFetchTransactions()
    }

    func showError(error: Error) {
        output?.showError(error: error)
    }
}
