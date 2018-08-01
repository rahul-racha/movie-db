//
//  ExploreViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/28/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import SearchTextField

protocol MovieDetailsDelegate {
    func setMovieDetails(from movList: [String:String])
}

class ExploreViewController: UIViewController {

    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var exploredMoviesView: UITableView!
    @IBOutlet weak var searchImgView: UIImageViewX!
    @IBOutlet weak var descLabel: UILabelX!
    
    var movdb: MovieDbService = MovieDbService()
    var diskRef: DiskManager = DiskManager()
    var filteredMovies = [[String: Any]]()
    var imageContainer = [UIImage]()
    var delegate: MovieDetailsDelegate?
    var activityIndicator: UIActivityIndicatorView?
    var isSearchTapped: Bool = false
    var isCellTapped: Bool = false
    var isResponseDelayed: Bool = false
    var isNetworkReachable: Bool = true
    let imageBasePath = "Movies/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exploredMoviesView.delegate = self
        exploredMoviesView.dataSource = self
        exploredMoviesView.isHidden = true
        self.descLabel.isHidden = false
        exploredMoviesView.tableFooterView = UIView()
        customizeSearchTextField()
        addGestures()
        addObservers()
        if (ReachabilityManager.shared.isNetworkAvailable) {
            self.handleOnlineData()
        } else {
            self.handleOfflineData()
        }
    }
    
    func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.searchTapped(gesture:)))
        searchImgView.addGestureRecognizer(tapGesture)
        searchImgView.isUserInteractionEnabled = true
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveMoviesInfo(_:)), name: .searchKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOfflineData), name: .offlineKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOnlineData), name: .onlineKey, object: nil)
    }
    
    func customizeSearchTextField() {
        searchTextField.theme = SearchTextFieldTheme.lightTheme()
        searchTextField.theme.font = UIFont.systemFont(ofSize: 12)
        //searchTextField.theme.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        searchTextField.theme.separatorColor = UIColor (red: 0, green: 0, blue: 0, alpha: 0.5)
        searchTextField.theme.bgColor = UIColor (red: 1, green: 1, blue: 1, alpha: 1)
        searchTextField.comparisonOptions = [.caseInsensitive]
        searchTextField.maxNumberOfResults = 5
        
        searchTextField.userStoppedTypingHandler = {
            if (false == self.isNetworkReachable) {
                AlertManager.openSingleActionAlert(target: self, title: "No Network", message: "Check your internet connection and try again", action: "OK")
                return
            }
            self.isSearchTapped = false
            self.isCellTapped = false
            if let criteria = self.searchTextField.text {
                if criteria.count > 1 {
                   self.searchTextField.showLoadingIndicator()
                    self.isResponseDelayed = true
                    self.movdb.getMovies(withTitle: criteria, {
                        (results) -> Void in
                        print("get movies call returned")
                       NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.handleDelayResponse), object: nil)
                        self.perform(#selector(self.handleDelayResponse), with: nil, afterDelay: 10.0)
                    })
                }
            }
        }
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            self.setActivityIndicator()
            DispatchQueue.global(qos: .userInteractive).async {
                let item = filteredResults[itemPosition]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
                detailVC.movieDetails = self.filteredMovies[itemPosition]
                detailVC.modalPresentationStyle = .overCurrentContext
                DispatchQueue.main.async {
                    self.searchTextField.text = item.title
                    self.searchTextField.hideResultsList()
                    self.exploredMoviesView.isHidden = true
                    self.descLabel.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        self.activityIndicator?.removeFromSuperview()
                        self.present(detailVC, animated: true, completion: nil)
                    })
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.searchTextField.hideResultsList()
    }
    
    @objc func handleOnlineData() {
        DispatchQueue.main.async {
            self.isNetworkReachable = true
            self.searchTextField.placeholder = "Enter movie titles"
        }
    }
    
    @objc func handleOfflineData() {
        DispatchQueue.main.async {
            self.isNetworkReachable = false
            self.searchTextField.placeholder = "Network is not reachable"
        }
    }
    
    @objc func searchTapped(gesture: UIGestureRecognizer) {
        if (false == isNetworkReachable) {
            AlertManager.openSingleActionAlert(target: self, title: "No Network", message: "Check your internet connection and try again", action: "OK")
            return
        }
        
        if (searchTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            AlertManager.openSingleActionAlert(target: self, title: "Empty", message: "Text field should not be empty", action: "OK")
            return
        }
        self.exploredMoviesView.isHidden = true
        self.descLabel.isHidden = false
        setActivityIndicator()
        self.searchTextField.hideResultsList()
        self.searchTextField.stopLoadingIndicator()
        isSearchTapped = true
        self.isResponseDelayed = true
        if (gesture.view as? UIImageView) != nil {
            self.movdb.getMovies(withTitle: searchTextField.text!, {
                (results) -> Void in
                print("get movies call returned")
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.handleDelayResponse), object: nil)
                self.perform(#selector(self.handleDelayResponse), with: nil, afterDelay: 10.0)
            })
        }
    }
    
    @objc func handleDelayResponse() {
        if (true == self.isResponseDelayed) {
            if (false == isCellTapped && false == isSearchTapped) {
                searchTextField.stopLoadingIndicator()
            } else {
                activityIndicator?.removeFromSuperview()
            }
            AlertManager.openSingleActionAlert(target: self, title: "No result", message: "High delay in response. Try some other term", action: "OK")
        }
    }
    
    @objc func receiveMoviesInfo(_ notification: NSNotification) {
        self.filteredMovies = notification.userInfo!["movies"] as! [[String: Any]]
        self.isResponseDelayed = false
        self.searchTextField.stopLoadingIndicator()
//        guard let results = movieDict! else {
//            self.searchTextField.stopLoadingIndicator()
//            return
//        }
        if (false == isSearchTapped && false == isCellTapped) {
            prepareSearchSuggestions(using: self.filteredMovies)
        } else {
            if (true == isSearchTapped) {
                prepareTableViewItems()
            }
        }
    }
    
    func createImageContainer() {
        self.imageContainer.removeAll()
        for result in self.filteredMovies {
            let tempImg = self.diskRef.getImage(movieDBRef: self.movdb, isNetworkReachable: self.isNetworkReachable, id: result["id"] as! Int, imageBasePath: self.imageBasePath, path: result["poster_path"] as? String, imgSize: MovieDbService.PosterSize.w92)
            self.imageContainer.append(tempImg)
        }
    }
    
    func prepareTableViewItems() {
        self.createImageContainer()
        self.exploredMoviesView.reloadData()
//        exploredMoviesView.isHidden = false
//        descLabel.isHidden = true
        searchTextField.hideResultsList()
        //activityIndicator?.removeFromSuperview()
    }
    
    func prepareSearchSuggestions(using results: [[String: Any]]) {
        var items = [SearchTextFieldItem]()
        DispatchQueue.global(qos: .userInteractive).async {
            var counter: Int = 1
            for movie in results {
                let posterImg = self.diskRef.getImage(movieDBRef: self.movdb, isNetworkReachable: self.isNetworkReachable, id: movie["id"] as! Int, imageBasePath: self.imageBasePath, path: movie["poster_path"] as? String, imgSize: MovieDbService.PosterSize.w92)
                    var title = ""
                    var releaseDate = ""
                    if (movie["original_title"] != nil) {
                        title = movie["original_title"] as! String
                    }
                
                    if (movie["release_date"] != nil) {
                        releaseDate = movie["release_date"] as! String
                    }
                    let item = SearchTextFieldItem(title: title, subtitle: releaseDate, image: posterImg)
                    items.append(item)
                    counter += 1
                    if (counter > 5) {
                        break
                    }
            }
            DispatchQueue.main.async {
                if (false == self.isSearchTapped && false == self.isCellTapped) {
                    self.searchTextField.filterItems(items)
                    self.searchTextField.stopLoadingIndicator()
                }
            }
        }
    }
}

extension ExploreViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont(name: "Futura", size: 17)
        header?.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Results"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploredMovieCell", for: indexPath) as! ExploreMovieTableViewCell
        if let title = self.filteredMovies[indexPath.row]["original_title"] as? String {
            cell.titleLabel.text = title
        } else {
            cell.titleLabel.text = "Unknown"
        }
        
        if let date = self.filteredMovies[indexPath.row]["release_date"] as? String {
            cell.releaseLabel.text = date
        } else {
            cell.releaseLabel.text = "Unknown"
        }
        cell.moviePosterView.image = self.imageContainer[indexPath.row]
        exploredMoviesView.isHidden = false
        descLabel.isHidden = true
        activityIndicator?.removeFromSuperview()
        return cell
    }
}

extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ExploreMovieTableViewCell
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        cell.releaseLabel.textColor = UIColor.black
//        self.exploredMoviesView.isHidden = true
//        self.descLabel.isHidden = false
        self.setActivityIndicator()
        self.activityIndicator?.bringSubview(toFront: self.exploredMoviesView)
        self.isCellTapped = true
        self.searchTextField.stopLoadingIndicator()
        //DispatchQueue.global(qos: .userInteractive).async {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
        detailVC.movieDetails = self.filteredMovies[indexPath.row]
        detailVC.modalPresentationStyle = .overCurrentContext
        //DispatchQueue.main.async {
        self.activityIndicator?.removeFromSuperview()
//            self.exploredMoviesView.isHidden = false
//            self.descLabel.isHidden = true
        backgroundView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = backgroundView
        cell.releaseLabel.textColor = UIColor.white
        self.present(detailVC, animated: true, completion: nil)
        //}
        //}
    }
}

extension Notification.Name {
    static let searchKey = Notification.Name("com.homes.search")
}
