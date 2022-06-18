//
//  AccountEditorService.swift
//  Accountant
//
//  Created by Roman Topchii on 10.06.2022.
//

import Foundation
import CoreData

protocol AccountEditorServiceDelegate: AnyObject {
    func isValidName(_ isValid: Bool)
    func typeDidSet(_ accountType: AccountTypeViewModel?)
    func currencyDidSet(_ currency: CurrencyViewModel?)
    func holderDidSet(_ holder: HolderViewModel?)
    func keeperDidSet(_ keeper: KeeperViewModel?)
    func currencyIsAccounting(_ isAccounting: Bool)
    func errorHandler(_ error: Error)
}

class AccountEditorService {

    var currencyId: UUID {
        get {
            return account.currency!.id
        }
        set {
            setCurrency(newValue)
        }
    }
    var holderId: UUID? {
        get {
            return account.holder?.id
        }
        set {
            setHolder(newValue)
        }
    }
    var keeperId: UUID? {
        get {
            return account.keeper?.id
        }
        set {
            setKeeper(newValue)
        }
    }

    var balance: Double = 0
    var linkedAccountBalance: Double = 0
    var rate: Double = 1

    weak var delegate: AccountEditorServiceDelegate?

    private(set) var persistentContainer: PersistentContainer
    private var context: NSManagedObjectContext

    private let parent: Account
    private var account: Account

    private var isValidName: Bool = false
    private var isValidType: Bool = false

    init(persistentContainer: PersistentContainer, parentAccountId: UUID) {
        self.persistentContainer = persistentContainer
        self.context = persistentContainer.newBackgroundContext()

        guard let parent = AccountHelper.getAccountWithId(parentAccountId, context: self.context)
        else {fatalError("Parent should exists, otherwise there is wrong app logic")}

        self.parent = parent

        guard let defultType = parent.type.defultChildType else {
            fatalError("defultChildType should exists if we use this service. " +
                       "use condition accountType.child.isEmpty == false")
        }
        let currency = CurrencyHelper.getAccountingCurrency(context: context)
        self.account = Account(parent: parent, name: "", type: defultType, currency: currency, keeper: nil, holder: nil,
                               context: context)
    }

    func parentType() -> UUID {
        return parent.type.id
    }

    func setType(_ typeId: UUID) throws {
        guard let type = parent.type.childrenList.filter({$0.id == typeId}).first else {
            isValidType = false
            throw ServiceError.paretnTypeDoesntHasChildWithId
        }
        isValidType = true
        account.type = type
    }

    private func setCurrency(_ currencyId: UUID) {
        do {
            guard let currency = CurrencyHelper.getById(currencyId, context: context)
            else {throw ServiceError.currencyWithIdNotFound}
            account.currency = currency
            delegate?.currencyDidSet(CurrencyViewModel(currency))
            delegate?.currencyIsAccounting(currency.isAccounting)
        } catch let error {
            delegate?.errorHandler(error)
        }
    }

    private func setHolder(_ holderId: UUID?) {
        do {
            guard let holderId = holderId
            else {
                account.holder = nil
                delegate?.holderDidSet(nil)
                return
            }
            guard let holder = HolderHelper.getById(holderId, context: context)
            else {
                throw ServiceError.holderWithIdNotFound

            }

            account.holder = holder
            delegate?.holderDidSet(HolderViewModel(holder))
        } catch let error {
            delegate?.errorHandler(error)
        }
    }

    private func setKeeper(_ keeperId: UUID?) {
        do {
            guard let keeperId = keeperId else {
                account.keeper = nil
                delegate?.keeperDidSet(nil)
                return
            }
            guard let keeper = KeeperHelper.getById(keeperId, context: context)
            else {
                throw ServiceError.keeperWithIdNotFound

            }

            account.keeper = keeper
            delegate?.keeperDidSet(KeeperViewModel(keeper))
        } catch let error {
            delegate?.errorHandler(error)
        }
    }

    func setName(_ name: String) {
        if parent.childrenList.filter({$0.name == name}).isEmpty {
            if AccountHelper.isReservedAccountName(name) {
                delegate?.isValidName(false)
                isValidName = false
            } else {
                delegate?.isValidName(true)
                isValidName = true
            }
        } else {
            delegate?.isValidName(false)
            isValidName = false
        }
        delegate?.isValidName(isValidName)
    }

    enum ServiceError: AppError {
        case paretnTypeDoesntHasChildWithId
        case holderWithIdNotFound
        case keeperWithIdNotFound
        case currencyWithIdNotFound
    }
}
