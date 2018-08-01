//
//  ViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/27/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTxtView: UITextView!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var releaseDataLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var delBarButton: UIBarButtonItem!
    
    
    var movieDetails = [String: Any]()
    var activityIndicator: UIActivityIndicatorView?
    let imageBasePath = "Movies/"
    var isNetworkReachable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        self.navigationController?.navigationBar.isTranslucent = false
        DispatchQueue.global(qos: .userInteractive).async {
            self.setBarButtonsStatus()
        }
        initViewContent()
        activityIndicator?.removeFromSuperview()
    }
    

    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.view.addSubview(activityIndicator!)
        activityIndicator?.frame = view.bounds
        activityIndicator?.startAnimating()
    }
    
    func setBarButtonsStatus() {
        let mvmRef = MovieViewModel()
        let id = movieDetails["id"] as! Int
        let status = mvmRef.checkMovieExistsInDb(id: id)
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
        self.posterImgView.image = UIImage(named: "70253257-loading-wallpapers.jpeg")
        let movdb = MovieDbService()
        let diskRef = DiskManager()
        //self.setActivityIndicator()
        //self.activityIndicator?.bringSubview(toFront: self.posterImgView)
        DispatchQueue.global(qos: .userInteractive).async {
          let tempImg  = diskRef.getImage(movieDBRef: movdb, isNetworkReachable: self.isNetworkReachable, id: self.movieDetails["id"] as! Int, imageBasePath: self.imageBasePath, path: self.movieDetails["poster_path"] as? String, imgSize: MovieDbService.PosterSize.original)
            DispatchQueue.main.async {
                //self.posterImgView.willRemoveSubview(self.activityIndicator!)
                //self.activityIndicator?.removeFromSuperview()
                self.posterImgView.image = tempImg
            }
        }
        if let titleTxt = movieDetails["original_title"] as? String {
            titleLabel.text = titleTxt
        } else {
            titleLabel.text = "Unknown"
        }
        
        if let overview = movieDetails["overview"] as? String {
            overviewTxtView.text = overview
        } else {
            overviewTxtView.text = "Unknown"
        }
        
        if let popularityTxt = movieDetails["popularity"] as? String {
            popularityLabel.text = String(format: "%.3f",popularityTxt)
        } else {
            popularityLabel.text = "Unknown"
        }
        
        if let releaseTxt = movieDetails["release_date"] as? String {
            releaseDataLabel.text = releaseTxt
        } else {
            releaseDataLabel.text = "Unknown"
        }
        
    }
    
    @IBAction func saveMovie(_ sender: UIBarButtonItem) {
        self.setActivityIndicator()
        let mvmRef = MovieViewModel()
        let diskRef = DiskManager()
        let movdb = MovieDbService()
        let diskPath = diskRef.saveImageToDisk(movieDBRef: movdb, imageBasePath: self.imageBasePath, posterPath: movieDetails["poster_path"] as? String, id: movieDetails["id"] as! Int)
        movieDetails["local_path"] = diskPath
        let status = mvmRef.saveMovieToDb(dataDict: movieDetails)
        self.activityIndicator?.removeFromSuperview()
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
        self.setActivityIndicator()
        let mvmRef = MovieViewModel()
        let status = mvmRef.delMovieFromDb(withID: movieDetails["id"] as! Int)
        self.activityIndicator?.removeFromSuperview()
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


