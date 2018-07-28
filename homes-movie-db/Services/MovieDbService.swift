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
    
    enum PosterSize: String {
        case w185 = "w185"
        case w500 = "w500"
        case original = "original"
    }
    
    init() {
        TMDBConfig.apikey = MovieDbService.apiKey
    }
    
    func getMovies(withTitle title: String, _ completion: @escaping ([MovieMDB]?) -> ()) {
        //var movieList: [MovieMDB]?
        SearchMDB.movie(query: title, language: "en", page: 1, includeAdult: true, year: nil, primaryReleaseYear: nil) {
            data, movies in
            print(movies?[0].original_title)
            print(movies?[0].overview)
            print(movies?[0].poster_path)
            print(movies?[0].video)
            print(movies?.count)
            completion(movies)
        }
    }
}
