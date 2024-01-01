//
//  RemoteConfigValues.swift
//  Accountant
//
//  Created by Roman Topchii on 30.12.2023.
//

import Foundation
import Firebase

class RemoteConfigValues {
    static let shared = RemoteConfigValues()
    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false
    private let defaultOffer = "pro_access_all_app"
    private var currentBuild = {
        if let dictionary = Bundle.main.infoDictionary,
           let buildString = dictionary["CFBundleVersion"] as? String,
           let build = Int(buildString) {
            return build
        }
        return 1
    }()

    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }

    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            RCValueKey.activeOffer.rawValue: self.defaultOffer,
            RCValueKey.latestAppBuild.rawValue: self.currentBuild
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }

    func activateDebugMode() {
        let settings = RemoteConfigSettings()
        // TODO: Set Live value
        // WARNING: Don't actually do this in production! (SET Live value - 43200)
        settings.minimumFetchInterval = 43200
        settings.fetchTimeout = 10
        RemoteConfig.remoteConfig().configSettings = settings
    }

    func fetchCloudValues() {
        activateDebugMode()

        // Fetching values from the Firebase Cloud
        RemoteConfig.remoteConfig().fetch { [weak self] _, error in
            if let error = error {
                print("Uh-oh. Got an error fetching remote values \(error)")
                DispatchQueue.main.async {
                    self?.loadingDoneCallback?()
                }
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

    func getActiveOffer() -> String {
        return RemoteConfig.remoteConfig()[RCValueKey.activeOffer.rawValue]
            .stringValue ?? self.defaultOffer
    }

    func getLatestAppBuild() -> Int {
        let build = RemoteConfig.remoteConfig()[RCValueKey.latestAppBuild.rawValue].stringValue
        guard let build = build else {return currentBuild}
        return Int(build) ?? self.currentBuild
    }

    enum RCValueKey: String {
        case activeOffer
        case latestAppBuild
    }
}
