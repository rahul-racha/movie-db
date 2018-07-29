//
//  Movie.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/29/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object {
    @objc dynamic var posterPath = ""
    @objc dynamic var isAdult: Bool = false
    @objc dynamic var overview = ""
    @objc dynamic var releaseDate = ""
    @objc dynamic var genreIDs = [Int]()
    @objc dynamic var id: Int = 0
    @objc dynamic var originalTitle = ""
    @objc dynamic var originalLang = ""
    @objc dynamic var title = ""
    @objc dynamic var backdropPath = ""
    @objc dynamic var popularity: Double = 0
    @objc dynamic var voteCount: Double = 0
    @objc dynamic var isVideo: Bool = false
    @objc dynamic var voteAverage: Double = 0
    
    func makeMovie(posterPath: String, isAdult: Bool, overview: String, releaseDate: String, genreIDs: [Int], id: Int,
        originalTitle: String, originalLang: String,
        title: String, backdropPath: String, popularity: Double,
        voteCount: Double, isVideo: Bool, voteAverage: Double) {
        self.posterPath = posterPath
    }
    
    func saveObject() -> Bool {
        let realm = try! Realm()
        let temp = realm.objects(Movie.self)
        let currentCount = temp.endIndex
        try! realm.write {
            realm.add(self)
        }
        var result = false
        let movie = realm.objects(Movie.self)
        if (movie.endIndex > currentCount) {
            result = true
        }
        return result
    }
    
    
}
