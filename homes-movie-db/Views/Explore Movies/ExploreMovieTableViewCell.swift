//
//  ExploreMovieTableViewCell.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 7/30/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import UIKit

class ExploreMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var moviePosterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
