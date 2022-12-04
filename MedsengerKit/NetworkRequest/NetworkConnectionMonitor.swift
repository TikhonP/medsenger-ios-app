//
//  NetworkConnectionMonitor.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 04.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import Network

class NetworkConnectionMonitor: ObservableObject {
    static let shared = NetworkConnectionMonitor()
    
    @Published private(set) var isConnected = false
    @Published private(set) var isCellular = false
    
    private let nwMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkConnectionMonitor")
    
    public func checkConnection() {
        nwMonitor.pathUpdateHandler = { [weak self] newPath in
            DispatchQueue.main.async {
                self?.isConnected = newPath.status == .satisfied
                self?.isCellular = newPath.usesInterfaceType(.cellular)
            }
        }
        nwMonitor.start(queue: queue)
    }
    
    public func stop() {
        nwMonitor.cancel()
    }
}