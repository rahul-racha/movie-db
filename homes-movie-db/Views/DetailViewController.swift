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
    var msgFrame: UIView?
    var imageBasePath: String = "Movies/"
    var isNetworkReachable: Bool = ReachabilityManager.shared.isNetworkAvailable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delBarButton.isEnabled = false
        self.saveBarButton.isEnabled = false
        self.navigationController?.navigationBar.isTranslucent = false
        initViewContent()
    }
    

    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setActivityIndicator() {
        self.msgFrame = UIView(frame: CGRect(x: self.view.frame.midX - 25, y: self.view.frame.midY - 25 , width: 50, height: 50))
        self.msgFrame?.layer.cornerRadius = 10
        self.msgFrame?.backgroundColor = UIColor.purple
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        self.activityIndicator?.frame = (self.msgFrame?.bounds)!
        self.msgFrame?.addSubview(self.activityIndicator!)
        self.view.addSubview(self.msgFrame!)
        self.activityIndicator?.startAnimating()
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
        DispatchQueue.global(qos: .userInteractive).async {
          let tempImg  = diskRef.getImage(movieDBRef: movdb, isNetworkReachable: self.isNetworkReachable, id: self.movieDetails["id"] as! Int, imageBasePath: self.imageBasePath, path: self.movieDetails["poster_path"] as? String, imgSize: MovieDbService.PosterSize.original)
              self.setBarButtonsStatus()
            DispatchQueue.main.async {
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
//        self.setActivityIndicator()
//        self.msgFrame?.bringSubview(toFront: self.posterImgView)
        let mvmRef = MovieViewModel()
        let diskRef = DiskManager()
        let movdb = MovieDbService()
        let diskPath = diskRef.saveImageToDisk(movieDBRef: movdb, imageBasePath: self.imageBasePath, posterPath: movieDetails["poster_path"] as? String, id: movieDetails["id"] as! Int)
        movieDetails["local_path"] = diskPath
        let status = mvmRef.saveMovieToDb(dataDict: movieDetails)
        //self.msgFrame?.removeFromSuperview()
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
        //self.setActivityIndicator()
        let mvmRef = MovieViewModel()
        let status = mvmRef.delMovieFromDb(withID: movieDetails["id"] as! Int)
        //self.msgFrame?.removeFromSuperview()
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


