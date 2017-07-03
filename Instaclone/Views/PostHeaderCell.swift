//
//  PostHeaderCell.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/30/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {
    static let height: CGFloat = 54

    @IBOutlet weak var usernameLabel: UILabel!
    @IBAction func optionButtonTapped(_ sender: Any) {
        print("option button tapped")
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
