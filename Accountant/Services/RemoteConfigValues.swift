//
//  RemoteConfigValues.swift
//  Accountant
//
//  Created by Roman Topchii on 30.12.2023.
//

import Foundation
import Firebase

class RemoteConfigValues {
    static let sharedInstance = RemoteConfigValues()
    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false
    let defaultOffer = "pro_access_all_app"

    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }

    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            RCValueKey.activeOffer.rawValue: self.defaultOffer
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }

    func activateDebugMode() {
        let settings = RemoteConfigSettings()
        // TODO: Set Live value
        // WARNING: Don't actually do this in production! (SET Live value - 43200)
        settings.minimumFetchInterval = 43200
        RemoteConfig.remoteConfig().configSettings = settings
    }

    func fetchCloudValues() {
      // Activating mode
      activateDebugMode()

      // Fetching values from the Firebase Cloud
      RemoteConfig.remoteConfig().fetch { [weak self] _, error in
        if let error = error {
          print("Uh-oh. Got an error fetching remote values \(error)")
          return
        }

        // Activating values
        RemoteConfig.remoteConfig().activate { _, _ in
            self?.fetchComplete = true
            DispatchQueue.main.async {
              self?.loadingDoneCallback?()
            }
        }
      }
    }

    func getActiveOffer(forKey key: RCValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.rawValue]
            .stringValue ?? self.defaultOffer
    }
}

enum RCValueKey: String {
    case activeOffer
}
