//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-21.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    
    var imageUrl: String?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
