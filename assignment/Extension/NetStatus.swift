//
//  NetStatus.swift
//  assignment
//
//  Created by Moo Maa on 27/01/2021.
//

import Foundation
import Network

class NetStatus {
    
    // MARK: - Properties
    static let shared = NetStatus()
    
    var monitor: NWPathMonitor?
    var isMonitoring = false

    var netStatusChangeHandler: (() -> Void)?

    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }

    // MARK: - Init & Deinit
    private init() {}


    // MARK: - Method Implementation
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetStatus_Monitor")
        monitor?.start(queue: queue)
        
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
        
        isMonitoring = true
    }
}
