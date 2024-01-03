//
//  SettingsViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 26.11.2023.
//

import UIKit
import UniformTypeIdentifiers

class SettingsViewModel: PaidAccessViewModel {

    public var accountingCurrency = Dynamic("")

    private(set) var environment: Dynamic<Environment> = Dynamic(CoreDataStack.shared.activeEnvironment)
    private(set) var router: SettingsRouter
    private(set) var settingsList: [SettingsItem] = []

    override init() {
        router = SettingsRouter()
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
    }

    override func handleError(_ error: Error) {
        router.route(to: .error(error))
    }

    func reloadData() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        accountingCurrency.value = CurrencyHelper.getAccountingCurrency(context: context)?.code ?? ""

        settingsList.removeAll()
        for item in SettingsItem.allCases {
            if(item == .envirement && UserProfileService.isAppLaunchedBefore() == false)
                || (item == .startAccounting && UserProfileService.isAppLaunchedBefore() == true)
                || (item == .auth && userPaidAccessData.value.hasPaidAccess == false)
                || item == .importAccounts
                || item == .exportAccounts
                || item == .userGuides
                || item == .exchangeRates {
                // will be hidden
            } else {
                settingsList.append(item)
            }
        }
    }

    func didSelectRow(row: Int) {
        // swiftlint:disable:this function_body_length cyclomatic_complexity line_length
        switch settingsList[row] {
        case .offer:
            router.route(to: .offerVC)
        case .accountsManager:
            router.route(to: .accountNavVC)
        case .importAccounts:
            if AccessManager.canImportExportEntities(environment: environment.value,
                                                     isUserHasPaidAccess: userPaidAccessData.value.hasPaidAccess) {
                router.route(to: .openDocumentPickerVC)
            } else {
                router.route(to: .offerVC)
            }
        case .importTransactions:
            if AccessManager.canImportExportEntities(environment: environment.value,
                                                     isUserHasPaidAccess: userPaidAccessData.value.hasPaidAccess) {
                router.route(to: .openDocumentPickerVC)
            } else {
                router.route(to: .offerVC)
            }
        case .exportAccounts:
            if AccessManager.canImportExportEntities(environment: environment.value,
                                                     isUserHasPaidAccess: userPaidAccessData.value.hasPaidAccess) {
                shareFile(fileName: "AccountList", data: ImportExportAccountWorker.exportAccountsToString(context: CoreDataStack.shared.persistentContainer.viewContext))
            } else {
                router.route(to: .offerVC)
            }
        case .exportTransactions:
            if AccessManager.canImportExportEntities(environment: environment.value,
                                                     isUserHasPaidAccess: userPaidAccessData.value.hasPaidAccess) {
                shareFile(fileName: "TransactionList",
                          data: TransactionHelper.exportTransactionsToString(context: CoreDataStack.shared.persistentContainer.viewContext))
            } else {
                router.route(to: .offerVC)
            }
        case .termsOfUse:
            router.route(to: .termsOfUse)
        case .privacyPolicy:
            router.route(to: .privacyPolicy)
        case .startAccounting:
            router.route(to: .startAccounting(self.router.viewController?.parent))
        case .userGuides:
            router.route(to: .userGuide)
        case .bankProfiles:
            router.route(to: .bankProfilesVC)
        case .exchangeRates:
            router.route(to: .exchange)
        case .archive:
            router.route(to: .archive)
        default:
            break
        }
    }

    public func importAccounts(data: String) {
        do {
            let backGroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
            try ImportExportAccountWorker.importAccounts(data, context: backGroundContext)
            try CoreDataStack.shared.saveContext(backGroundContext)
        } catch let error {
            router.route(to: .error(error))
        }
    }

    public func switchEnvironment(_ isTestEnvronment: Bool) {
        do {
            if isTestEnvronment {
                CoreDataStack.shared.switchPersistentStore(.test)
                try CoreDataStack.shared.restorePersistentStore(.test)
                try SeedDataService.addTestData(persistentContainer: CoreDataStack.shared.persistentContainer)
            } else if !isTestEnvronment && CoreDataStack.shared.activeEnvironment == .test {
                CoreDataStack.shared.switchPersistentStore(.prod)
            }

            NotificationCenter.default.post(name: .environmentDidChange, object: nil)
        } catch let error {
            router.route(to: .error(error))
        }
    }
    
    public func getAppVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let bundle = dictionary["CFBundleVersion"] as? String
        else {return ""}

        return "\(NSLocalizedString("App version", tableName: Constants.Localizable.settingsVC, comment: "")) \(version) (\(bundle))" // swiftlint:disable:this line_length
    }

    @objc private func environmentDidChange() {
        self.environment.value = CoreDataStack.shared.activeEnvironment
    }
}

extension SettingsViewModel {
    private func shareFile(fileName: String, data: String) {
        let docDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
        if let fileURL = docDirectory?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            do {
                try data.write(to: fileURL, atomically: true, encoding: .utf8)
                router.route(to: .share(filesToShare: [fileURL]))
            } catch let error {
                router.route(to: .error(error))
            }
        }
    }
}

extension SettingsViewModel {
    enum SettingsItem: String, CaseIterable {
        case offer = "Purchase offer"
        case startAccounting = "Start accounting"
        case auth = "Auth"
        case envirement = "Test mode"
        case accountingCurrency = "Accounting currency"
        case archive = "Archiving"
        case accountsManager = "Account manager"
        case bankProfiles = "Bank profiles"
        case exchangeRates = "Exchange rates"
        case importAccounts = "Import account list"
        case importTransactions = "Import transaction list"
        case exportAccounts = "Export account list"
        case exportTransactions = "Export transaction list"
        case userGuides = "User guides"
        case termsOfUse = "Terms of use"
        case privacyPolicy = "Privacy policy"
    }
}
