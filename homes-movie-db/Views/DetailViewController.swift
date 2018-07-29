//
//  ViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/27/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import TMDBSwift
import RealmSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backdropImgView: UIImageView!
    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTxtView: UITextView!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var releaseDataLabel: UILabel!
    
    var movieDetails: MovieMDB?
    var posterImg: UIImage?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        self.edgesForExtendedLayout = []
        initViewContent()
        activityIndicator?.removeFromSuperview()
    }
    

    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(activityIndicator!)
        activityIndicator?.frame = view.bounds
        activityIndicator?.startAnimating()
    }
    
    func initViewContent() {
        
        let service = MovieDbService()
        if let posterImg = service.getPosterImage(fromPath: movieDetails?.poster_path, size: MovieDbService.PosterSize.original) {
            posterImgView.image = posterImg
        } else {
            posterImgView.image = UIImage(named: "cinema-64154.jpg")
        }
        
        if let mov = movieDetails {
            if let titleTxt = mov.original_title {
                titleLabel.text = titleTxt
            } else {
                titleLabel.text = "N/A"
            }
            
            if let overview = mov.overview {
                overviewTxtView.text = overview
            } else {
                overviewTxtView.text = "N/A"
            }
            
            if let popularityTxt = mov.popularity {
                popularityLabel.text = String(format: "%.3f",popularityTxt)
            } else {
                popularityLabel.text = "Unknown"
            }
            
            if let releaseTxt = mov.release_date {
                releaseDataLabel.text = releaseTxt
            } else {
                releaseDataLabel.text = "Unknown"
            }
        
        }
    }
    
    @IBAction func saveMovie(_ sender: UIBarButtonItem) {

        let mvmRef = MovieViewModel()
        mvmRef.saveMovieToDb(posterPath: movieDetails?.poster_path, isAdult: (movieDetails?.adult)!, overview: movieDetails?.overview, releaseDate: movieDetails?.release_date, genreIDs: movieDetails?.genre_ids, id: (movieDetails?.id)!, originalTitle: movieDetails?.original_title, originalLang: movieDetails?.original_language, title: movieDetails?.title, backdropPath: movieDetails?.backdrop_path, popularity: movieDetails?.popularity, voteCount: movieDetails?.vote_count, isVideo: movieDetails?.video, voteAverage: movieDetails?.vote_average)
        
    }
    
    
}

//extension DetailViewController: MovieDetailsDelegate {
//    func setMovieDetails(from movList: [String:String]) {
//        movieDetails = movList
//    }
//}

