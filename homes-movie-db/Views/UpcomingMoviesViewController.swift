//
//  UpcomingMoviesViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/31/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import TMDBSwift

class UpcomingMoviesViewController: UIViewController {

    @IBOutlet weak var upcomingMovieColView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate let reuseIdentifier = "upcomingMovieCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate var movieContainer = [MovieMDB]()
    fileprivate var filteredContainer = [MovieMDB]()
    var movdb = MovieDbService()
    var activityIndicator: UIActivityIndicatorView?
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        upcomingMovieColView.delegate = self
        upcomingMovieColView.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder = "Filter upcoming movies"
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveUpcomingMoviesInfo(_:)), name: .upcomingKey, object: nil)
        movdb.getUpcomingMovies()
        
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
    
    @objc func receiveUpcomingMoviesInfo(_ notification: NSNotification) {
        movieContainer = notification.userInfo!["upcoming"] as! [MovieMDB]
        filteredContainer = movieContainer
        upcomingMovieColView.reloadData()
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
        DispatchQueue.global(qos: .userInteractive).async {
            if let path = self.filteredContainer[indexPath.row].poster_path {
                DispatchQueue.main.async {
                    cell.upcomingPosterView.image = self.movdb.getPosterImage(fromPath: path, size: MovieDbService.PosterSize.w185)
                }
            } else {
                DispatchQueue.main.async {
                    cell.upcomingPosterView.image = UIImage(named: "cinema-64154.jpg")
                }
            }
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
                let _ = self.upcomingMovieColView.cellForItem(at: indexPath) as! UpcomingMovieCollectionViewCell
                self.activityIndicator?.removeFromSuperview()
                self.present(detailVC, animated: true, completion: nil)
            }
        }
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
        filteredContainer = searchText.isEmpty ? movieContainer : movieContainer.filter { (item: MovieMDB) -> Bool in
            return item.original_title?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        setActivityIndicator()
        upcomingMovieColView.reloadData()
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
    static let upcomingKey = Notification.Name("com.homes.upcoming")
}
