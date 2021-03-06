//
//  MovieViewModel.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/29/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation

class MovieViewModel {
    func saveMovieToDb(dataDict: [String: Any]) -> Bool {
        
        var poster = "", ov = "", rdate = "", oTitle = ""
        var lPath = "", oLang = "", t = "", bPath = ""
        var vid = false
        var pop: Double = 0, vCount: Double = 0, vAvg: Double = 0
        
        if dataDict["poster_path"] != nil {
            poster = dataDict["poster_path"] as! String
        }
        
        if dataDict["local_path"] != nil {
            lPath = dataDict["local_path"] as! String
        }
        if dataDict["overview"] != nil {
            ov = dataDict["overview"] as! String
        }
        
        if dataDict["release_date"] != nil {
            rdate = dataDict["release_date"] as! String
        }
        
        if dataDict["original_title"] != nil {
            oTitle = dataDict["original_title"] as! String
        }
        
        if dataDict["original_language"] != nil {
            oLang = dataDict["original_language"] as! String
        }
        
        if dataDict["title"] != nil {
            t = dataDict["title"] as! String
        }
        
        if dataDict["backdrop_path"] != nil {
            //bPath = dataDict["backdrop_path"] as! String
        }
        
        if dataDict["popularity"] != nil {
            pop = dataDict["popularity"] as! Double
        }
        
        if dataDict["vote_count"] != nil {
            vCount = dataDict["vote_count"] as! Double
        }
        
        if dataDict["video"] != nil {
            vid = dataDict["video"] as! Bool
        }
        
        if dataDict["vote_average"] != nil {
            vAvg = dataDict["vote_average"] as! Double
        }
        
        let isAdult = dataDict["adult"] as! Bool
        let id = dataDict["id"] as! Int
        
        let movRef = Movie()
        movRef.makeMovie(posterPath: poster, localPath: lPath,  isAdult: isAdult, overview: ov, releaseDate: rdate, id: id, originalTitle: oTitle, originalLang: oLang, title: t, backdropPath: bPath, popularity: pop, voteCount: vCount, isVideo: vid, voteAverage: vAvg)
        return movRef.saveObject()
    }
    
    func convertMovieToDict(movie: Movie) -> [String: Any] {
        let movieDict: [String: Any] = [
            "poster_path": movie.posterPath,
            "local_path": movie.localPath,
            "adult": movie.isAdult,
            "overview": movie.overview,
            "release_date": movie.releaseDate,
            "id": movie.id,
            "original_title": movie.originalTitle,
            "original_language": movie.originalLang,
            "title": movie.title,
            "backdrop_path": movie.backdropPath,
            "popularity": movie.popularity,
            "vote_count": movie.voteCount,
            "video": movie.isVideo,
            "vote_average": movie.voteAverage
        ]
        return movieDict
    }
    
    func getMovies() -> [[String: Any]] {
        let movRef = Movie()
        let results = Array(movRef.getMovies())
        var moviesDict = [[String: Any]]()
        for movie in results {
            let temp = convertMovieToDict(movie: movie)
            moviesDict.append(temp)
        }
        return moviesDict
    }
    
    func delMovieFromDb(withID id: Int) -> Bool{
        let movRef = Movie()
        return movRef.delMovie(withID: id)
    }
    
    func checkMovieExistsInDb(id: Int) -> Bool {
        let movRef = Movie()
        if let movie = movRef.getMovie(withID: id) {
            if (movie.id == id) {
                return true
            }
        }
        return false
    }
}
