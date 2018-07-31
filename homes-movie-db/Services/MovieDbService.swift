//
//  MovieDbService.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/29/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation
import TMDBSwift

class MovieDbService {
    private static let apiKey: String = "f0a72670d4db6d7186c51e06dcb33abc"
    static let basePosterPath: String = "https://image.tmdb.org/t/p/"
    let searchKey = "com.homes.search"
    let topKey = "com.homes.top"
    
    enum PosterSize: String {
        case w92 = "w92"
        case w185 = "w185"
        case w500 = "w500"
        case original = "original"
    }
    
    init() {
        TMDBConfig.apikey = MovieDbService.apiKey
    }
    
    func getMovies(withTitle title: String, _ completion: @escaping ([MovieMDB]?) -> ()) {
        SearchMDB.movie(query: title, language: "en", page: 1, includeAdult: true, year: nil, primaryReleaseYear: nil) {
            data, movies in
            print(movies?[0].original_title)
            print(movies?[0].overview)
            print(movies?[0].poster_path)
            print(movies?[0].video)
            print(movies?.count)
            print(movies?[0].genres)
            let notificationObj = ["movies": movies]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.searchKey), object: nil, userInfo: notificationObj)
        }
        completion(nil)
    }
    
    func getTopMovies() {
        MovieMDB.toprated(language: "en", page: 1){
            data, topRatedMovies in
            if let movie = topRatedMovies{
                print(movie[0].title)
                print(movie[0].original_title)
                print(movie[0].release_date)
                print(movie[0].overview)
                let notificationObj = ["top": movie]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.topKey), object: nil, userInfo: notificationObj)
            }
        }
    }
    
    func getPosterImage(fromPath path: String?, size: PosterSize) -> UIImage? {
        guard let pathUrl = path else {
            return nil
        }
        let posterPath = MovieDbService.basePosterPath + size.rawValue + "/" +  pathUrl
        var poster: UIImage?
        let url = URL(string:posterPath)
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data)!
            poster = image
        }
        return poster
    }
}
