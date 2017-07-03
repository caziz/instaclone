//
//  FindFriendsCell.swift
//  Instaclone
//
//  Created by Christopher Aziz on 7/3/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit

protocol FindFriendsCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell)
}

class FindFriendsCell: UITableViewCell {
    
    
    
    // MARK: - Properties

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: FindFriendsCellDelegate?

    // MARK: - Cell Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // aesthetic
        
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
    }
    
    // MARK: - IBActions
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        delegate?.didTapFollowButton(sender, on: self)

    }
    
}
