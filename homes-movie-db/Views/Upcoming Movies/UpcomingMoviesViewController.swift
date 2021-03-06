//
//  UpcomingMoviesViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/31/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit

class UpcomingMoviesViewController: UIViewController {

    @IBOutlet weak var upcomingMovieColView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate let reuseIdentifier = "upcomingMovieCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate var movieContainer = [[String: Any]]()
    fileprivate var filteredContainer = [[String: Any]]()
    fileprivate var imageContainer = [UIImage]()
    fileprivate var filteredImgContainer = [UIImage]()
    fileprivate static var isMoviesSaved: Bool = false
    var mapIDToIndexContainer = [Int: Int]()
    var movdb = MovieDbService()
    var diskRef = DiskManager()
    var activityIndicator: UIActivityIndicatorView?
    var msgFrame: UIView?
    var searchController: UISearchController!
    var isNetworkReachable: Bool = ReachabilityManager.shared.isNetworkAvailable
    let imageBasePath = "Upcoming_Movies/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upcomingMovieColView.delegate = self
        upcomingMovieColView.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder = "Filter upcoming movies"
        DispatchQueue.global(qos: .background).async {
            self.saveTabPosition()
        }
        self.addObservers()
        //if (1 != FeatureViewModel.launchPosition) {
            if (ReachabilityManager.shared.isNetworkAvailable) {
                self.handleOnlineData()
            } else {
                self.handleOfflineData()
            }
        //}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //ReachabilityManager.shared.startMonitoring()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUpcomingMoviesInfo(_:)), name: .upcomingKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOfflineData), name: .offlineKey1, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOnlineData), name: .onlineKey1, object: nil)
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
    
    func saveTabPosition() {
        let ref = FeatureViewModel()
        if (ref.delPosition()) {
            let _ = ref.saveFeatureToDb(position: 1)
        }
    }
    
    @objc func handleOnlineData() {
        DispatchQueue.main.async {
            self.searchBar.placeholder = "Filter upcoming movies"
            self.isNetworkReachable = true
            self.setActivityIndicator()
            self.movdb.getUpcomingMovies()
        }
    }
    
    @objc func handleOfflineData() {
        DispatchQueue.main.async {
            self.setActivityIndicator()
            self.searchBar.placeholder = "Filter in offline mode"
            self.isNetworkReachable = false
            self.movieContainer = self.getUpcomingMoviesFromDb()
            if (0 == self.movieContainer.count) {
                AlertManager.openSingleActionAlert(target: self, title: "No Data", message: "Movies are not saved. Please check your network and try again", action: "OK")
                self.msgFrame?.removeFromSuperview()
                return
            }
            
            self.filteredContainer = self.movieContainer
            self.createImageContainer()
            self.upcomingMovieColView.reloadData()
            self.msgFrame?.removeFromSuperview()
        }
    }
    
    @objc func receiveUpcomingMoviesInfo(_ notification: NSNotification) {
        movieContainer = notification.userInfo!["upcoming"] as! [[String: Any]]
        filteredContainer = movieContainer
        self.createImageContainer()
        upcomingMovieColView.reloadData()
        self.msgFrame?.removeFromSuperview()
        DispatchQueue.global(qos: .background).async {
            self.saveUpcomingMoviesToDb()
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
    
    func saveUpcomingMoviesToDb() {
        let fmvmRef = UpcomingMovieViewModel()
        let _ = fmvmRef.delMovies()
        for upMovie in movieContainer {
            var temp = upMovie
            let diskPath = diskRef.saveImageToDisk(movieDBRef: self.movdb, imageBasePath: self.imageBasePath, posterPath: temp["poster_path"] as? String, id: temp["id"] as! Int)
            temp["local_path"] = diskPath
            let _ = fmvmRef.saveMovieToDb(dataDict: temp)
        }
    }
    
    func getUpcomingMoviesFromDb() -> [[String: Any]] {
        let fmvmRef = UpcomingMovieViewModel()
        let movieDict = fmvmRef.getMovies()
        return movieDict
    }
}

extension UpcomingMoviesViewController: UICollectionViewDataSource,
UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredContainer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,for: indexPath) as! UpcomingMovieCollectionViewCell
        cell.upcomingPosterView.image = self.filteredImgContainer[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.setActivityIndicator()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
        detailVC.movieDetails = self.filteredContainer[indexPath.row]
        //detailVC.imageBasePath = self.imageBasePath
        detailVC.modalPresentationStyle = .overCurrentContext
        let _ = self.upcomingMovieColView.cellForItem(at: indexPath) as! UpcomingMovieCollectionViewCell
        self.msgFrame?.removeFromSuperview()
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension UpcomingMoviesViewController: UICollectionViewDelegateFlowLayout {
    
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

extension UpcomingMoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredImgContainer.removeAll()
        filteredContainer = searchText.isEmpty ? movieContainer : movieContainer.filter { (item: [String: Any]) -> Bool in
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
        self.upcomingMovieColView.reloadData()
        //activityIndicator?.removeFromSuperview()
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
    static let upcomingKey = Notification.Name("com.homes.upcoming")
    static let offlineKey1 = Notification.Name("com.homes.offline1")
    static let onlineKey1 = Notification.Name("com.homes.online1")
}

