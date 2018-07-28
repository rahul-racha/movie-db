//
//  Support.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/29/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation
import UIKit

struct AlertManager {
    
    static func openSingleActionAlert(target: UIViewController,title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        target.present(alert, animated: true)
    }
}
