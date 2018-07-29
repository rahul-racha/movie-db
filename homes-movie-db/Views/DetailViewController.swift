//
//  ViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/27/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backdropImgView: UIImageView!
    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    var movieDetails = [String:String]()
    var posterImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewContent()
    }
    

    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initViewContent() {
        posterImgView.image = posterImg
        posterImgView.contentMode = .scaleAspectFill
        titleLabel.text = movieDetails["original_title"]
        overviewLabel.text = movieDetails["overview"]
        popularityLabel.text = movieDetails["popularity"]
    }
    
}

//extension DetailViewController: MovieDetailsDelegate {
//    func setMovieDetails(from movList: [String:String]) {
//        movieDetails = movList
//    }
//}

