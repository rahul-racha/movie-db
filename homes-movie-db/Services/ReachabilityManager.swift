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
    let offlineKey0 = "com.homes.offline0"
    let offlineKey1 = "com.homes.offline1"
    let offlineKey2 = "com.homes.offline2"
    let onlineKey0 = "com.homes.online0"
    let onlineKey1 = "com.homes.online1"
    let onlineKey2 = "com.homes.online2"
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
            isNetworkAvailable = false
            debugPrint("Network became unreachable")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.offlineKey0), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.offlineKey0), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.offlineKey2), object: nil)
        case .reachableViaWiFi, .reachableViaWWAN:
            isNetworkAvailable = true
            debugPrint("Network reachable through WiFi or Cellular Data")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.onlineKey0), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.onlineKey1), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.onlineKey2), object: nil)
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
