//
//  HomeViewController.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/27/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var posts : [Post] = []
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()

    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        UserService.posts(for: User.current) { (posts) in
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    // MARK: - AESTHETIC
    
    func configureTableView() {
        // remove separators for empty cells
         tableView.tableFooterView = UIView()
        // remove separators from cells
         tableView.separatorStyle = .none
    }

}


// MARK: - UITableViewDataSource

extension HomeViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // header, image, action cells
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostHeaderCell") as! PostHeaderCell
            cell.usernameLabel.text = User.current.username
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostImageCell") as! PostImageCell
            let imageURL = URL(string: post.imageURL)
            cell.postImageView.kf.setImage(with: imageURL)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostActionCell") as! PostActionCell
            cell.delegate = self
            configureCell(cell, with: post)
            
            return cell
            
        default:
            fatalError("Error: unexpected indexPath.")
        }
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        cell.likeCountLabel.text = "\(post.likeCount) likes"
    }
}


// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            let post = posts[indexPath.section]
            return post.imageHeight
            
        case 2:
            return PostActionCell.height
            
        default:
            fatalError()
        }
    }
}

// MARK: - PostActionCellDelegate

extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        // First we make sure that an index path exists for the the given cell. We'll need the index path of the cell later on to reference the correct post.
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        // Set the isUserInteractionEnabled property of the UIButton to false so the user doesn't accidentally send multiple requests by tapping too quickly.
        likeButton.isUserInteractionEnabled = false
        // Reference the correct post corresponding with the PostActionCell that the user tapped.
        let post = posts[indexPath.section]
        
        // Use our LikeService to like or unlike the post based on the isLiked property.
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            // Use defer to set isUserInteractionEnabled to true whenever the closure returns.
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            // Basic error handling if something goes wrong with our network request.
            guard success else { return }
            
            // Change the likeCount and isLiked properties of our post if our network request was successful.
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            // Get a reference to the current cell.
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            // Update the UI of the cell on the main thread. Remember that all UI updates must happen on the main thread.
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
    }
}





