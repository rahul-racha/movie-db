//
//  Feature.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 8/1/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation
import RealmSwift

class Feature: Object {
    @objc dynamic var tabPosition: Int = 0
    
    func makeFeature(position: Int) {
        self.tabPosition = position
    }
    
    func saveObject() -> Bool {
        let realm = try! Realm()
        let temp = realm.objects(Feature.self)
        let currentCount = temp.endIndex
        try! realm.write {
            realm.add(self)
        }
        var result = false
        let movie = realm.objects(Feature.self)
        print(movie)
        if (movie.endIndex > currentCount) {
            result = true
        }
        return result
    }
    
    func getFeatures() -> Results<Feature> {
        let realm = try! Realm()
        let movies = realm.objects(Feature.self)
        return movies;
    }
    
    func delFeatures() -> Bool {
        let realm = try! Realm()
        let movies = realm.objects(Feature.self)
        var counter = false
        try! realm.write {
            realm.delete(movies)
            counter = true
        }
        return counter
    }
    
}
