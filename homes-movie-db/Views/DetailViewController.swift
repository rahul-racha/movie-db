//
//  ViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/27/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import TMDBSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTxtView: UITextView!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var releaseDataLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var delBarButton: UIBarButtonItem!
    
    
    var movieDetails: MovieMDB?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        self.navigationController?.navigationBar.isTranslucent = false
        initViewContent()
        DispatchQueue.global(qos: .userInteractive).async {
            self.setBarButtonsStatus()
        }
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
    
    func setBarButtonsStatus() {
        let mvmRef = MovieViewModel()
        let status = mvmRef.checkMovieExistsInDb(id: (movieDetails?.id)!)
        DispatchQueue.main.async {
            if (true == status) {
                self.saveBarButton.isEnabled = false
                self.delBarButton.isEnabled = true
            } else {
                self.saveBarButton.isEnabled = true
                self.delBarButton.isEnabled = false
            }
        }
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
        let status = mvmRef.saveMovieToDb(posterPath: movieDetails?.poster_path, isAdult: (movieDetails?.adult)!, overview: movieDetails?.overview, releaseDate: movieDetails?.release_date, genreIDs: movieDetails?.genre_ids, id: (movieDetails?.id)!, originalTitle: movieDetails?.original_title, originalLang: movieDetails?.original_language, title: movieDetails?.title, backdropPath: movieDetails?.backdrop_path, popularity: movieDetails?.popularity, voteCount: movieDetails?.vote_count, isVideo: movieDetails?.video, voteAverage: movieDetails?.vote_average)
        if status == true {
            saveBarButton.isEnabled = false
            delBarButton.isEnabled = true
            AlertManager.openSingleActionAlert(target: self, title: "Success", message: "Movie is successfully saved", action: "OK")
        } else {
            saveBarButton.isEnabled = true
            delBarButton.isEnabled = false
            AlertManager.openSingleActionAlert(target: self, title: "Failed", message: "Movie is not saved", action: "OK")
        }
    }
    
    @IBAction func deleteMovie(_ sender: UIBarButtonItem) {
        let mvmRef = MovieViewModel()
        let status = mvmRef.delMovieFromDb(withID: (movieDetails?.id)!)
        if status == true {
            saveBarButton.isEnabled = true
            delBarButton.isEnabled = false
            AlertManager.openSingleActionAlert(target: self, title: "Success", message: "Movie is successfully deleted", action: "OK")
        } else {
            saveBarButton.isEnabled = false
            delBarButton.isEnabled = true
            AlertManager.openSingleActionAlert(target: self, title: "Failed", message: "Movie is not deleted", action: "OK")
        }
    }
    
}

//extension NSLayoutConstraint
//{
//    @IBInspectable var iPhone4_Constant: CGFloat
//        {
//        set{
//            //Only apply value to iphone 4 devices.
//            if (UIScreen.main.bounds.size.height < 500)
//            {
//                self.constant = newValue;
//            }
//        }
//        get
//        {
//            return self.constant;
//        }
//    }
//}
//extension DetailViewController: MovieDetailsDelegate {
//    func setMovieDetails(from movList: [String:String]) {
//        movieDetails = movList
//    }
//}

