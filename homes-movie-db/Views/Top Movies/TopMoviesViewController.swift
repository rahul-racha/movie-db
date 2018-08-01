//
//  TopMoviesViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/31/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit

class TopMoviesViewController: UIViewController {

    @IBOutlet weak var topMovieColView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate let reuseIdentifier = "topMovieCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate var topMovieContainer = [[String: Any]]()
    fileprivate var filteredContainer = [[String: Any]]()
    fileprivate var imageContainer = [UIImage]()
    fileprivate var filteredImgContainer = [UIImage]()
    var mapIDToIndexContainer = [Int: Int]()
    var movdb = MovieDbService()
    var diskRef = DiskManager()
    var activityIndicator: UIActivityIndicatorView?
    var searchController: UISearchController!
    var isNetworkReachable: Bool = ReachabilityManager.shared.isNetworkAvailable
    let imageBasePath = "Top_Movies/"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.topMovieColView.delegate = self
        self.topMovieColView.dataSource = self
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Filter top movies"
        DispatchQueue.global(qos: .background).async {
            self.saveTabPosition()
        }
        self.addObservers()
        if (0 != FeatureViewModel.launchPosition) {
            if (ReachabilityManager.shared.isNetworkAvailable) {
                self.handleOnlineData()
            } else {
                self.handleOfflineData()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveTopMoviesInfo(_:)), name: .topKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOfflineData), name: .offlineKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOnlineData), name: .onlineKey, object: nil)
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(activityIndicator!)
        activityIndicator?.frame = view.bounds
        activityIndicator?.startAnimating()
    }
    
    func saveTabPosition() {
        let ref = FeatureViewModel()
        ref.delPosition()
        ref.saveFeatureToDb(position: 0)
    }
    
    @objc func handleOfflineData() {
        DispatchQueue.main.async {
            self.searchBar.placeholder = "Filter in offline mode"
            self.isNetworkReachable = false
            self.setActivityIndicator()
            self.topMovieContainer = self.getTopMoviesFromDb()
            if (0 == self.topMovieContainer.count) {
                AlertManager.openSingleActionAlert(target: self, title: "No Data", message: "Movies are not saved. Please check your network and try again", action: "OK")
            }
            self.filteredContainer = self.topMovieContainer
            self.createImageContainer()
            self.topMovieColView.reloadData()
        }
    }
    
    @objc func handleOnlineData() {
        DispatchQueue.main.async {
            self.searchBar.placeholder = "Filter top movies"
            self.isNetworkReachable = true
            self.setActivityIndicator()
            self.movdb.getTopMovies()
        }
    }
    
    @objc func receiveTopMoviesInfo(_ notification: NSNotification) {
        topMovieContainer = notification.userInfo!["top"] as! [[String: Any]]
        filteredContainer = topMovieContainer
        self.createImageContainer()
        topMovieColView.reloadData()
        DispatchQueue.global(qos: .background).async {
            self.saveTopMoviesToDb()
        }
    }
    
    func createImageContainer() {
        self.imageContainer.removeAll()
        self.filteredImgContainer.removeAll()
        self.mapIDToIndexContainer.removeAll()
        var counter: Int = 0
        for movie in self.filteredContainer {
            let id = movie["id"] as! Int
            self.mapIDToIndexContainer[id] = counter
            let tempImg = self.diskRef.getImage(movieDBRef: self.movdb, isNetworkReachable: self.isNetworkReachable, id: movie["id"] as! Int,imageBasePath: self.imageBasePath, path: movie["poster_path"] as? String, imgSize: MovieDbService.PosterSize.w185)
            self.imageContainer.append(tempImg)
            counter += 1
        }
        self.filteredImgContainer = self.imageContainer
    }
    
    func saveTopMoviesToDb() {
        let fmvmRef = TopMovieViewModel()
        let _ = fmvmRef.delMovies()
        for topMovie in topMovieContainer {
            var temp = topMovie
            let diskPath = diskRef.saveImageToDisk(movieDBRef: self.movdb, imageBasePath: self.imageBasePath, posterPath: temp["poster_path"] as? String, id: temp["id"] as! Int)
            temp["local_path"] = diskPath
            let _ = fmvmRef.saveMovieToDb(dataDict: temp)
        }
    }
    
    func getTopMoviesFromDb() -> [[String: Any]] {
        let fmvmRef = TopMovieViewModel()
        let movieDict = fmvmRef.getMovies()
        return movieDict
    }
}

extension TopMoviesViewController: UICollectionViewDataSource,
UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredContainer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,for: indexPath) as! TopMovieCollectionViewCell
        cell.topMovPosterView.image = self.filteredImgContainer[indexPath.row]
        self.activityIndicator?.removeFromSuperview()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = self.topMovieColView.cellForItem(at: indexPath) as! TopMovieCollectionViewCell
        self.setActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
            detailVC.movieDetails = self.filteredContainer[indexPath.row]
            detailVC.isNetworkReachable = self.isNetworkReachable
            detailVC.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.async {
                self.activityIndicator?.removeFromSuperview()
                self.present(detailVC, animated: true, completion: nil)
            }
        }
    }
}

extension TopMoviesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow+1)
        let availWidth = view.frame.width - paddingSpace
        let itemWidth = availWidth/itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

}

extension TopMoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredImgContainer.removeAll()
        filteredContainer = searchText.isEmpty ? topMovieContainer : topMovieContainer.filter { (item: [String: Any]) -> Bool in
            let id = item["id"] as! Int
            let title = item["original_title"] as? String
            let condition = title?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil)
            if condition != nil {
                self.filteredImgContainer.append(self.imageContainer[self.mapIDToIndexContainer[id]!])
            }
            return condition != nil
        }
        if (searchText.isEmpty) {
            self.filteredImgContainer = self.imageContainer
        }
        //setActivityIndicator()
        self.topMovieColView.reloadData()
        //self.activityIndicator?.removeFromSuperview()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

extension Notification.Name {
    static let topKey = Notification.Name("com.homes.top")
    static let offlineKey = Notification.Name("com.homes.offline")
    static let onlineKey = Notification.Name("com.homes.online")
}

