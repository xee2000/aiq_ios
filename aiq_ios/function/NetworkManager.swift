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
            let status = path.status == .satisfied
            if status {
                RestApi.isConnected = status
                RestApi.shared.Loading()

            } else {
                RestApi.isConnected = status
                RestApi.shared.Loading()
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
