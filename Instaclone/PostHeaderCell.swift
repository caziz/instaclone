//
//  PostHeaderCell.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/30/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBAction func optionButtonTapped(_ sender: UIButton) {
        print("option button tapped")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
