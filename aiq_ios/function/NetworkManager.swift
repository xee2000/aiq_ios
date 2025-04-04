//
//  NetworkManager.swift
//  aiq_ios
//
//  Created by 이정호 on 4/3/25.
//

import Foundation
import Network

class NetworkManager {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    static let shared = NetworkManager()

    init() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                RestApi.sendGyroInformation(count: 1111)
                RestApi.sendPendingRestApiRequests()
            } else {}
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
