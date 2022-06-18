//
//  TransactionListInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import Purchases

class TransactionListInteractor {

    weak var output: TransactionListInteractorOutput?
    private var isUserHasPaidAccess: Bool = false
    private let coreDataStack = CoreDataStack.shared
    private var environment = Environment.prod
    private var service: TransactionListService

    init(dataProvider: TransactionListService) {

        self.environment = coreDataStack.persistentContainer.environment
        self.service = dataProvider
        self.service.delegate = self
        self.service.provideData()

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
        service.changePersistentContainer(coreDataStack.persistentContainer)
        service.provideData()
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
        service.duplicateTransaction(at: indexPath)
    }

    func deleteTransaction(at indexPath: IndexPath) {
        service.deleteTransaction(at: indexPath)
    }

    func search(text: String) {
        service.search(text: text)
    }

    func numberOfSections() -> Int {
       return service.numberOfSections()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return service.numberOfRowsInSection(section)
    }

    func transactionAt(_ indexPath: IndexPath) -> TransactionViewModel {
        return service.transactionAt(indexPath)
    }
}

// MARK: - TransactionListProviderDelegate
extension TransactionListInteractor: TransactionListServiceDelegate {
    func didFetchTransactions() {
        output?.didFetchTransactions()
    }

    func showError(error: Error) {
        output?.showError(error: error)
    }
}
