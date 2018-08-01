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
    let offlineKey = "com.homes.offline"
    let onlineKey = "com.homes.online"
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    var isNetworkAvailable : Bool = false
//    {
//        get {
//            return reachabilityStatus != .notReachable
//        }
//        set(newValue) {
//            print("isNetworkAvailable updated")
//        }
//    }
    let reachability = Reachability()!
    
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
            isNetworkAvailable = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.offlineKey), object: nil)
        case .reachableViaWiFi, .reachableViaWWAN:
            isNetworkAvailable = true
            debugPrint("Network reachable through WiFi or Cellular Data")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.onlineKey), object: nil)
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
