//
//  ExploreViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/28/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import SearchTextField
import TMDBSwift

protocol MovieDetailsDelegate {
    func setMovieDetails(from movList: [String:String])
}

class ExploreViewController: UIViewController {

    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var exploredMoviesView: UITableView!
    @IBOutlet weak var searchImgView: UIImageViewX!
    var movdb: MovieDbService?
    var filteredMovies: [MovieMDB]?
    var delegate: MovieDetailsDelegate?
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exploredMoviesView.delegate = self
        exploredMoviesView.dataSource = self
        exploredMoviesView.isHidden = true
        movdb = MovieDbService()
        customizeSearchTextField()
        addGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveMoviesInfo(_:)), name: .searchKey, object: nil)
        
    }
    
    func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.searchTapped(gesture:)))
        searchImgView.addGestureRecognizer(tapGesture)
        searchImgView.isUserInteractionEnabled = true
    }
    
    func customizeSearchTextField() {
        searchTextField.theme = SearchTextFieldTheme.darkTheme()
        searchTextField.theme.font = UIFont.systemFont(ofSize: 12)
        //searchTextField.theme.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        searchTextField.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        searchTextField.theme.bgColor = UIColor (red: 0, green: 0, blue: 0, alpha: 0.7)
        searchTextField.comparisonOptions = [.caseInsensitive]
        searchTextField.maxNumberOfResults = 5
        
        searchTextField.userStoppedTypingHandler = {
            if let criteria = self.searchTextField.text {
                if criteria.count > 1 {
                   self.searchTextField.showLoadingIndicator()
                    
                    self.movdb?.getMovies(withTitle: criteria, {
                        (results) -> Void in
                        print("get movies call returned")
                    })
                    
//                   self.searchItemsFromMovieDb(withTitle: criteria, { (results) -> (Void) in
//                            print("search items is requested")
//                    })
                }
            }
        }
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            self.setActivityIndicator()
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if (item.title.range(of:")") != nil) {
                let endIndex = item.title.index(item.title.endIndex, offsetBy: -13)
                self.searchTextField.text = String(item.title[...endIndex])
            } else {
            self.searchTextField.text = item.title
            }
            let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
            detailVC.movieDetails = self.filteredMovies![itemPosition]
                //self.setDetailVCContent(index: itemPosition)
            detailVC.posterImg = item.image
            detailVC.modalPresentationStyle = .overCurrentContext
            self.activityIndicator?.removeFromSuperview()
            self.present(detailVC, animated: true, completion: nil)
        }
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(activityIndicator!)
        activityIndicator?.frame = view.bounds
        activityIndicator?.startAnimating()
    }
    
    func setDetailVCContent(index: Int) -> [String:String] {
        var movieDict = [String:String]()
        movieDict["poster_path"] = filteredMovies![index].poster_path
        movieDict["backdrop_path"] = filteredMovies![index].backdrop_path
        movieDict["original_title"] = filteredMovies![index].original_title
        movieDict["overview"] = filteredMovies![0].overview
        movieDict["release_date"] = filteredMovies![0].release_date
        if (filteredMovies![0].popularity != nil) {
        movieDict["popularity"] = String(format: "%.3f", filteredMovies![0].popularity!)
        } else {
            movieDict["popularity"] = "unknown"
        }
        return movieDict
    }
    
    @objc func searchTapped(gesture: UIGestureRecognizer) {
        if (searchTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            AlertManager.openSingleActionAlert(target: self, title: "Empty", message: "Text field should not be empty", action: "OK")
            return
        }
        if (gesture.view as? UIImageView) != nil {
            exploredMoviesView.isHidden = false
        }
    }
    
    func setPosterImage(fromPath path: String) -> UIImage? {
        var poster: UIImage?
        let url = URL(string:path)
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data)!
            poster = image
        }
        return poster
    }
    
    @objc func receiveMoviesInfo(_ notification: NSNotification) {
        let movieDict = notification.userInfo!["movies"] as? [MovieMDB]?
        if (movieDict == nil) {
            return
        }
        self.filteredMovies = movieDict!
        guard let results = movieDict! else {
            return
        }
        var items = [SearchTextFieldItem]()
        DispatchQueue.global(qos: .userInteractive).async {
            var counter: Int = 1
        for movie in results {
            var posterImg: UIImage?
            if (movie.poster_path == nil) {
                posterImg = UIImage(named: "cinema-64154.jpg")
            } else {
                
                let service = MovieDbService()
                posterImg = service.getPosterImage(fromPath: movie.poster_path, size: MovieDbService.PosterSize.w92)
//                let posterPath = MovieDbService.basePosterPath + MovieDbService.PosterSize.w92.rawValue + "/" +  movie.poster_path!
//                posterImg = self.setPosterImage(fromPath: posterPath)
            }
            var title = ""
            if (movie.original_title != nil) {
                if (movie.release_date != nil) {
                    title = movie.original_title! + " (" + movie.release_date! + ")"
                } else {
                    title = movie.original_title!
                }
            }
            let item = SearchTextFieldItem(title: title, subtitle: "", image: posterImg)
            items.append(item)
            counter += 1
            if (counter > 5) {
                break
            }
        }
            DispatchQueue.main.async {
                self.searchTextField.filterItems(items)
                self.searchTextField.stopLoadingIndicator()
            }
        }
    }
    
//    func searchItemsFromMovieDb(withTitle title: String, _ completion: @escaping ([SearchTextFieldItem]?) -> ()) {
//        self.movdb?.getMovies(withTitle: title, {
//            (results) -> Void in
//            print("get movies call returned")
//        })
//        completion(nil)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ExploreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploredMovieCell", for: indexPath) as! UITableViewCell
        return cell
    }
}

extension ExploreViewController: UITableViewDelegate {
    
}

extension Notification.Name {
    static let searchKey = Notification.Name("com.homes.search")
}
