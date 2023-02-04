//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by arthack on 24.01.2023.
//

import UIKit

class ImagesListCell: UITableViewCell {
    static let reuseIdentifire = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var dateLabel: UILabel!
}
