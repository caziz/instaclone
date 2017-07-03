//
//  PostActionCell.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/30/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit


class PostActionCell: UITableViewCell {
    static let height: CGFloat = 46
    
    // MARK: - Subviews
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        print("like button tapped")
    }
    
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
}
