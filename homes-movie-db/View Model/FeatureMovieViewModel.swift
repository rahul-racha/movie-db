//
//  FeatureMovieViewModel.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/31/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation

class FeatureMovieViewModel {
    func saveMovieToDb(posterPath: String?, localPath: String?, isAdult: Bool, overview: String?, releaseDate: String?, genreIDs: [Int]?, id: Int, originalTitle: String?, originalLang: String?,
                       title: String?, backdropPath: String?, popularity: Double?,
                       voteCount: Double?, isVideo: Bool?, voteAverage: Double?) -> Bool {
        
        var poster = "", ov = "", rdate = "", oTitle = ""
        var lPath = "", oLang = "", t = "", bPath = ""
        var vid = false
        var gIDs = [Int]()
        var pop: Double = 0, vCount: Double = 0, vAvg: Double = 0
        if posterPath != nil {
            poster = posterPath!
        }
        
        if localPath != nil {
            lPath = localPath!
        }
        if overview != nil {
            ov = overview!
        }
        
        if releaseDate != nil {
            rdate = releaseDate!
        }
        
        if genreIDs != nil {
            gIDs = genreIDs!
        }
        
        if originalTitle != nil {
            oTitle = originalTitle!
        }
        
        if originalLang != nil {
            oLang = originalLang!
        }
        
        if title != nil {
            t = title!
        }
        
        if backdropPath != nil {
            bPath = backdropPath!
        }
        
        if popularity != nil {
            pop = popularity!
        }
        
        if voteCount != nil {
            vCount = voteCount!
        }
        
        if isVideo != nil {
            vid = isVideo!
        }
        
        if voteAverage != nil {
            vAvg = voteAverage!
        }
        
        let movRef = FeatureMovie()
        movRef.makeMovie(posterPath: poster, localPath: lPath, isAdult: isAdult, overview: ov, releaseDate: rdate, id: id, originalTitle: oTitle, originalLang: oLang, title: t, backdropPath: bPath, popularity: pop, voteCount: vCount, isVideo: vid, voteAverage: vAvg)
        return movRef.saveObject()
    }
    
    func getMovies() -> [FeatureMovie] {
        let movRef = FeatureMovie()
        let results = Array(movRef.getMovies())
        return results
    }
    
    func delMovies() -> Bool {
        let movRef = FeatureMovie()
        return movRef.delMovies()
    }
}
