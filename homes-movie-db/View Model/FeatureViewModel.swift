//
//  FeatureViewModel.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 8/1/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation

class FeatureViewModel {
    static var launchPosition: Int = 0
    
    func saveFeatureToDb(position: Int) -> Bool {
        let ref = Feature()
        ref.makeFeature(position: position)
        return ref.saveObject()
    }
    
    func getPosition() -> Int {
        let ref = Feature()
        let results = Array(ref.getFeatures())
        if (results.count == 0) {
            return 0
        }
        return results[0].tabPosition
    }
    
    func delPosition() -> Bool {
        let ref = Feature()
        return ref.delFeatures()
    }
}
