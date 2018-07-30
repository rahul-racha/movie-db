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
    //@objc dynamic var genreIDs = [Int]()
    @objc dynamic var id: Int = 0
    @objc dynamic var originalTitle = ""
    @objc dynamic var originalLang = ""
    @objc dynamic var title = ""
    @objc dynamic var backdropPath = ""
    @objc dynamic var popularity: Double = 0
    @objc dynamic var voteCount: Double = 0
    @objc dynamic var isVideo: Bool = false
    @objc dynamic var voteAverage: Double = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func makeMovie(posterPath: String, isAdult: Bool, overview: String, releaseDate: String, id: Int,
        originalTitle: String, originalLang: String,
        title: String, backdropPath: String, popularity: Double,
        voteCount: Double, isVideo: Bool, voteAverage: Double) {
        self.posterPath = posterPath
        self.isAdult = isAdult
        self.overview = overview
        self.releaseDate = releaseDate
        self.id = id
        self.originalTitle = originalTitle
        self.originalLang = originalLang
        self.title = title
        self.backdropPath = backdropPath
        self.popularity = popularity
        self.voteCount = voteCount
        self.isVideo = isVideo
        self.voteAverage = voteAverage
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
        print(getMovies())
        if (movie.endIndex > currentCount) {
            result = true
        }
        return result
    }
    
    func getMovies() -> Results<Movie> {
        let realm = try! Realm()
        let movies = realm.objects(Movie.self)
        return movies
    }
    
    func getMovie(withID id: Int) -> Movie?  {
        let list = getMovies()
        let predicate = "id = " + String(id)
        let result = list.filter(predicate)
        let movie = Array(result)
        if movie.count == 1 {
            return movie[0]
        }
        return nil
    }
    
    func delMovie(withID id: Int) -> Bool {
        let realm = try! Realm()
        let list = getMovies()
        let predicate = "id = " + String(id)
        let result = list.filter(predicate)
        var counter = false
        try! realm.write {
            realm.delete(result)
            counter = true
        }
        return counter
    }
    
}
