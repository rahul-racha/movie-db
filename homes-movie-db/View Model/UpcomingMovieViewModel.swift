//
//  UpcomingMovieViewModel.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 8/1/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation

class UpcomingMovieViewModel {
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
            //MARK: unwrapping is still throwing error
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
        let movRef = UpcomingMovie()
        movRef.makeMovie(posterPath: poster, localPath: lPath, isAdult: isAdult, overview: ov, releaseDate: rdate, id: id, originalTitle: oTitle, originalLang: oLang, title: t, backdropPath: bPath, popularity: pop, voteCount: vCount, isVideo: vid, voteAverage: vAvg)
        return movRef.saveObject()
    }
    
    func getMovies() -> [[String: Any]] {
        let movRef = UpcomingMovie()
        let results = Array(movRef.getMovies())
        var moviesDict = [[String: Any]]()
        for movie in results {
            let temp = convertMovieToDict(featureMovie: movie)
            moviesDict.append(temp)
        }
        return moviesDict
    }
    
    func convertMovieToDict(featureMovie: UpcomingMovie) -> [String: Any] {
        let movieDict: [String: Any] = [
            "poster_path": featureMovie.posterPath,
            "local_path": featureMovie.localPath,
            "adult": featureMovie.isAdult,
            "overview": featureMovie.overview,
            "release_date": featureMovie.releaseDate,
            "id": featureMovie.id,
            "original_title": featureMovie.originalTitle,
            "original_language": featureMovie.originalLang,
            "title": featureMovie.title,
            "backdrop_path": featureMovie.backdropPath,
            "popularity": featureMovie.popularity,
            "vote_count": featureMovie.voteCount,
            "video": featureMovie.isVideo,
            "vote_average": featureMovie.voteAverage
        ]
        return movieDict
    }
    
    func delMovies() -> Bool {
        let movRef = UpcomingMovie()
        return movRef.delMovies()
    }
}

