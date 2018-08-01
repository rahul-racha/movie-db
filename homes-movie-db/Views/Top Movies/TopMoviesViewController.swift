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
    var msgFrame: UIView?
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
        //if (0 != FeatureViewModel.launchPosition) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveTopMoviesInfo(_:)), name: .topKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOfflineData), name: .offlineKey0, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOnlineData), name: .onlineKey0, object: nil)
    }
    
    func setActivityIndicator() {
//        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//        view.addSubview(activityIndicator!)
//        activityIndicator?.frame = view.bounds
//        activityIndicator?.startAnimating()
        self.msgFrame = UIView(frame: CGRect(x: self.view.frame.midX - 25, y: self.view.frame.midY - 25 , width: 50, height: 50))
        self.msgFrame?.layer.cornerRadius = 10
        self.msgFrame?.backgroundColor = UIColor.purple
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
//        self.activityIndicator?.frame = CGRect(x: self.msgFrame!.frame.midX - 0, y: self.msgFrame!.frame.midY - 0, width: 30, height: 30)
        self.activityIndicator?.frame = (self.msgFrame?.bounds)!
        self.msgFrame?.addSubview(self.activityIndicator!)
        self.view.addSubview(self.msgFrame!)
        self.activityIndicator?.startAnimating()
    }
    
    func saveTabPosition() {
        let ref = FeatureViewModel()
        if (ref.delPosition()) {
            let _ = ref.saveFeatureToDb(position: 0)
        }
    }
    
    @objc func handleOfflineData() {
        DispatchQueue.main.async {
            self.setActivityIndicator()
            self.searchBar.placeholder = "Filter in offline mode"
            self.isNetworkReachable = false
            self.topMovieContainer = self.getTopMoviesFromDb()
            if (0 == self.topMovieContainer.count) {
                AlertManager.openSingleActionAlert(target: self, title: "No Data", message: "Movies are not saved. Please check your network and try again", action: "OK")
                self.msgFrame?.removeFromSuperview()
                return
            }
            
            self.filteredContainer = self.topMovieContainer
            self.createImageContainer()
            self.topMovieColView.reloadData()
            self.msgFrame?.removeFromSuperview()
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
        self.msgFrame?.removeFromSuperview()
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = self.topMovieColView.cellForItem(at: indexPath) as! TopMovieCollectionViewCell
        self.setActivityIndicator()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
        detailVC.movieDetails = self.filteredContainer[indexPath.row]
        //detailVC.imageBasePath = self.imageBasePath
        detailVC.isNetworkReachable = self.isNetworkReachable
        detailVC.modalPresentationStyle = .overCurrentContext
        self.msgFrame?.removeFromSuperview()
        self.present(detailVC, animated: true, completion: nil)
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
        self.topMovieColView.reloadData()
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
    static let offlineKey0 = Notification.Name("com.homes.offline0")
    static let onlineKey0 = Notification.Name("com.homes.online0")
}

