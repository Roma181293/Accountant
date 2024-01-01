//
//  NetworkMonitor.swift
//  Accountant
//
//  Created by Roman Topchii on 01.01.2024.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isExpensive: Bool = true

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isExpensive = path.isExpensive
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
