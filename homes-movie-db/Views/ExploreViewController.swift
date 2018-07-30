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
    @IBOutlet weak var descLabel: UILabelX!
    
    var movdb: MovieDbService?
    var filteredMovies: [MovieMDB]?
    var delegate: MovieDetailsDelegate?
    var activityIndicator: UIActivityIndicatorView?
    var isSearchTapped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exploredMoviesView.delegate = self
        exploredMoviesView.dataSource = self
        exploredMoviesView.isHidden = true
        exploredMoviesView.tableFooterView = UIView()
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
        searchTextField.theme.bgColor = UIColor (red: 0, green: 0, blue: 0, alpha: 1)
        searchTextField.comparisonOptions = [.caseInsensitive]
        searchTextField.maxNumberOfResults = 5
        
        searchTextField.userStoppedTypingHandler = {
            self.isSearchTapped = false
            if let criteria = self.searchTextField.text {
                if criteria.count > 1 {
                   self.searchTextField.showLoadingIndicator()
                    
                    self.movdb?.getMovies(withTitle: criteria, {
                        (results) -> Void in
                        print("get movies call returned")
                    })
                }
            }
        }
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            self.setActivityIndicator()
            DispatchQueue.global(qos: .userInteractive).async {
                let item = filteredResults[itemPosition]
                print("Item at position \(itemPosition): \(item.title)")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
                detailVC.movieDetails = self.filteredMovies![itemPosition]
                    //self.setDetailVCContent(index: itemPosition)
                detailVC.modalPresentationStyle = .overCurrentContext
                DispatchQueue.main.async {
                    self.activityIndicator?.removeFromSuperview()
                    self.searchTextField.text = item.title
                    self.searchTextField.filterItems([])
                    self.searchTextField.hideResultsList()
                    self.exploredMoviesView.isHidden = false
                    self.present(detailVC, animated: true, completion: nil)
                }
            }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.searchTextField.filterItems([])
        self.searchTextField.hideResultsList()
    }
    
    @objc func searchTapped(gesture: UIGestureRecognizer) {
        if (searchTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            AlertManager.openSingleActionAlert(target: self, title: "Empty", message: "Text field should not be empty", action: "OK")
            return
        }
        setActivityIndicator()
        self.searchTextField.filterItems([])
        self.searchTextField.hideResultsList()
        self.searchTextField.stopLoadingIndicator()
        isSearchTapped = true
        if (gesture.view as? UIImageView) != nil {
            self.movdb?.getMovies(withTitle: searchTextField.text!, {
                (results) -> Void in
                print("get movies call returned")
            })
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
            self.searchTextField.stopLoadingIndicator()
            return
        }
        if (false == isSearchTapped) {
            prepareSearchSuggestions(using: results)
        } else {
            prepareTableViewItems(using: results)
        }
    }
    
    func prepareTableViewItems(using results: [MovieMDB]) {
        
        self.exploredMoviesView.reloadData()
        //isSearchTapped = false
        exploredMoviesView.isHidden = false
        descLabel.isHidden = true
        activityIndicator?.removeFromSuperview()
    }
    
    func prepareSearchSuggestions(using results: [MovieMDB]) {
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
                }
                var title = ""
                var releaseDate = ""
                if (movie.original_title != nil) {
                    title = movie.original_title!
                }
                
                if (movie.release_date != nil) {
                    releaseDate = movie.release_date!
                }
                let item = SearchTextFieldItem(title: title, subtitle: releaseDate, image: posterImg)
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont(name: "Futura", size: 17)
        header?.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Discover all your results!"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = filteredMovies {
            return results.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploredMovieCell", for: indexPath) as! ExploreMovieTableViewCell
        if let title = self.filteredMovies![indexPath.row].original_title {
            cell.titleLabel.text = title
        } else {
            cell.titleLabel.text = "Unknown"
        }
        
        if let date = self.filteredMovies![indexPath.row].release_date {
            cell.releaseLabel.text = date
        } else {
            cell.releaseLabel.text = "Unknown"
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let service = MovieDbService()
            if let posterImg = service.getPosterImage(fromPath: self.filteredMovies![indexPath.row].poster_path, size: MovieDbService.PosterSize.w92) {
                DispatchQueue.main.async {
                    cell.moviePosterView.image = posterImg
                }
            } else {
                DispatchQueue.main.async {
                    cell.moviePosterView.image = UIImage(named: "cinema-64154.jpg")
                }
            }
        }
        return cell
    }
}

extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.setActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
            detailVC.movieDetails = self.filteredMovies![indexPath.row]
            DispatchQueue.main.async {
                let _ = tableView.cellForRow(at: indexPath) as! ExploreMovieTableViewCell
                self.activityIndicator?.removeFromSuperview()
                self.present(detailVC, animated: true, completion: nil)
            }
        }
    }
}

extension Notification.Name {
    static let searchKey = Notification.Name("com.homes.search")
}
