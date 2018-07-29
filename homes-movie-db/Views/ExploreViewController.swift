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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exploredMoviesView.delegate = self
        exploredMoviesView.dataSource = self
        exploredMoviesView.isHidden = true
        movdb = MovieDbService()
        customizeSearchTextField()
        addGestures()
        // Do any additional setup after loading the view.
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
                    self.searchItemsFromMovieDb(withTitle: criteria, { (results) -> (Void) in
                        if (results.count > 0) {
                            self.searchTextField.filterItems(results)
                        }
                    })
                    self.searchTextField.stopLoadingIndicator()
                }
            }
        }
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.searchTextField.text = item.title
            var detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewStoryBoard") as! DetailViewController
            detailVC.movieDetails = self.setDetailVCContent(index: itemPosition)
            detailVC.posterImg = item.image
            detailVC.modalPresentationStyle = .overCurrentContext
            self.present(detailVC, animated: true, completion: nil)
        }
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
        //let imgWorker = DispatchQueue(label: "image-worker", qos: .utility)
        //imgWorker.async {
        let url = URL(string:path)
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data)!
            poster = image
        }
        //}
        return poster
    }
    
    func searchItemsFromMovieDb(withTitle title: String, _ completion: @escaping ([SearchTextFieldItem]) -> ()) {
        var items = [SearchTextFieldItem]()
        movdb?.getMovies(withTitle: title, {
            (results) -> Void in
            if (results == nil) {
                return
            }
            self.filteredMovies = results
            for movie in results! {
                let posterPath = MovieDbService.basePosterPath + MovieDbService.PosterSize.w185.rawValue + "/" +  movie.poster_path!
                let posterImg = self.setPosterImage(fromPath: posterPath)
                let item = SearchTextFieldItem(title: movie.original_title!, subtitle: "", image: posterImg)
                items.append(item)
            }
            completion(items)
        })
    }

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
