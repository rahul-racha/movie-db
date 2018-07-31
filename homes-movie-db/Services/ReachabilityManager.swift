//
//  ReachabilityManager.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/31/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation
import ReachabilitySwift

class ReachabilityManager: NSObject {
    static let shared = ReachabilityManager()
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .notReachable
    }
    let reachability = Reachability()!
    
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
        case .reachableViaWiFi:
            debugPrint("Network reachable through WiFi")
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
        }
    }
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }

}
