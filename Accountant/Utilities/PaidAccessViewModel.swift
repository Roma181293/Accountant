//
//  PaidAccessViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 26.11.2023.
//

import Foundation
import Purchases

class PaidAccessViewModel: NSObject {

    private(set) var userPaidAccessData: Dynamic<(hasPaidAccess: Bool, expirationDate: Date?)> = Dynamic((hasPaidAccess: false, expirationDate: nil))

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fetchAccessData),
                                               name: .receivedProAccessData,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    public func reloadUserAccessData() {
        fetchAccessData()
    }

    @objc private func fetchAccessData() {
        Purchases.shared.purchaserInfo { [weak self] (purchaserInfo, error) in
            if let error = error {
                self?.handleError(error)
            } else {
                if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                    let expirationDate = purchaserInfo?.expirationDate(forEntitlement: "pro")
                    self?.userPaidAccessData.value = (hasPaidAccess: true, expirationDate: expirationDate)
                } else {
                    self?.userPaidAccessData.value = (hasPaidAccess: false, expirationDate: nil)
                }
            }
        }
    }

    public func handleError(_ error: Error) {
    }
}
