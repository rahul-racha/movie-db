//
//  TopMoviesViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/31/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import TMDBSwift
import Disk

class TopMoviesViewController: UIViewController {

    @IBOutlet weak var topMovieColView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate let reuseIdentifier = "topMovieCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate var topMovieContainer = [MovieMDB]()
    fileprivate var filteredContainer = [MovieMDB]()
    var movdb = MovieDbService()
    var activityIndicator: UIActivityIndicatorView?
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        self.topMovieColView.delegate = self
        self.topMovieColView.dataSource = self
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Filter top movies"
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveTopMoviesInfo(_:)), name: .topKey, object: nil)
        self.movdb.getTopMovies()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(activityIndicator!)
        activityIndicator?.frame = view.bounds
        activityIndicator?.startAnimating()
    }
    
    @objc func receiveTopMoviesInfo(_ notification: NSNotification) {
        topMovieContainer = notification.userInfo!["top"] as! [MovieMDB]
        filteredContainer = topMovieContainer
        topMovieColView.reloadData()
        DispatchQueue.global(qos: .utility).async {
            self.saveTopMovies()
        }
    }
    
    func saveTopMovies() {
        let fmvmRef = FeatureMovieViewModel()
        for topMovie in topMovieContainer {
            let diskPath = saveImageToDisk(posterPath: topMovie.poster_path, id: topMovie.id)
            let _ = fmvmRef.saveMovieToDb(posterPath: topMovie.poster_path, localPath: diskPath, isAdult: (topMovie.adult)!, overview: topMovie.overview, releaseDate: topMovie.release_date, genreIDs: topMovie.genre_ids, id: (topMovie.id)!, originalTitle: topMovie.original_title, originalLang: topMovie.original_language, title: topMovie.title, backdropPath: topMovie.backdrop_path, popularity: topMovie.popularity, voteCount: topMovie.vote_count, isVideo: topMovie.video, voteAverage: topMovie.vote_average)
        }
    }
    
    func saveImageToDisk(posterPath: String?, id: Int) -> String? {
        guard let path = posterPath else {
            return nil
        }
        if let image = self.movdb.getPosterImage(fromPath: path, size: MovieDbService.PosterSize.original) {
            do {
                let destPath = "Top_Movies/"+String(id)+".jpg"
                try Disk.save(image, to: .documents, as: destPath)
                return destPath
            } catch {
                print("top movie image not saved")
            }
        }
        return nil
    }
    
    func getImageFromDisk(id: Int, path: String?) -> UIImage {
        if let image = self.movdb.getPosterImage(fromPath: path, size: MovieDbService.PosterSize.w185) {
            return image
        } else {
            return UIImage(named: "cinema-64154.jpg")!
        }
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
        DispatchQueue.global(qos: .userInteractive).async {
            cell.topMovPosterView.image = self.getImageFromDisk(id: self.filteredContainer[indexPath.row].id, path: self.filteredContainer[indexPath.row].poster_path)
            DispatchQueue.main.async {
                self.activityIndicator?.removeFromSuperview()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.setActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
            detailVC.movieDetails = self.filteredContainer[indexPath.row]
            DispatchQueue.main.async {
                let _ = self.topMovieColView.cellForItem(at: indexPath) as! TopMovieCollectionViewCell
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
        filteredContainer = searchText.isEmpty ? topMovieContainer : topMovieContainer.filter { (item: MovieMDB) -> Bool in
            return item.original_title?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        setActivityIndicator()
        topMovieColView.reloadData()
        activityIndicator?.removeFromSuperview()
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
}

