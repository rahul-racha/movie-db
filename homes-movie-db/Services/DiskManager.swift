//
//  DiskManager.swift
//  homes-movie-db
//
//  Created by Rahul Racha on 8/1/18.
//  Copyright © 2018 Rahul Racha. All rights reserved.
//

import Foundation
import Disk

class DiskManager {
    func saveImageToDisk(movieDBRef movdb: MovieDbService, imageBasePath: String, posterPath: String?, id: Int) -> String? {
        guard let path = posterPath else {
            return nil
        }
        if let image = movdb.getPosterImage(fromPath: path, size: MovieDbService.PosterSize.original) {
            do {
                let destPath = imageBasePath+String(id)+".jpg"
                try Disk.save(image, to: .documents, as: destPath)
                return destPath
            } catch {
                print("image not saved")
            }
        }
        return nil
    }
    
    func getImage(movieDBRef movdb: MovieDbService, isNetworkReachable: Bool, id: Int, imageBasePath: String, path: String?, imgSize: MovieDbService.PosterSize) -> UIImage {
        var retrievedImage: UIImage?
        if true == isNetworkReachable {
            if let image = movdb.getPosterImage(fromPath: path, size: imgSize) {
                retrievedImage = image
            } else {
                retrievedImage = UIImage(named: "cinema-64154.jpg")
            }
        } else {
            let destPath = imageBasePath+String(id)+".jpg"
            
            do {
                retrievedImage = try Disk.retrieve(destPath, from: .documents, as: UIImage.self)
            } catch {
                retrievedImage = UIImage(named: "cinema-64154.jpg")
            }
        }
        return retrievedImage!
    }
}
