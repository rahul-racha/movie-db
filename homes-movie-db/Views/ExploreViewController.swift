//
//  ExploreViewController.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/28/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit
import SearchTextField

class ExploreViewController: UIViewController {

    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var exploredMoviesView: UITableView!
    @IBOutlet weak var searchImgView: UIImageViewX!
    var movdb: MovieDbService?
    
    
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
                    let results = self.searchItemsFromMovieDb(withTitle: criteria)
                    if (results.count > 0) {
                        self.searchTextField.filterItems(results)
                    }
                    self.searchTextField.stopLoadingIndicator()
                }
            }
        }
        
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.searchTextField.text = item.title
        }
        
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
    
    func searchItemsFromMovieDb(withTitle title: String) -> [SearchTextFieldItem] {
        var items = [SearchTextFieldItem]()
        guard let results = movdb?.getMovies(withTitle: title) else {
            return items
        }
//        let item1 = SearchTextFieldItem(title: "Blue", subtitle: "Color", image: UIImage(named: "icon_blue"))
//        let item2 = SearchTextFieldItem(title: "Red", subtitle: "Color", image: UIImage(named: "icon_red"))
//        let item3 = SearchTextFieldItem(title: "Yellow", subtitle: "Color", image: UIImage(named: "icon_yellow"))
//        items = [item1]
        
        return items
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
