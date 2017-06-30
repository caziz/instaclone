//
//  HomeViewController.swift
//  Makestagram
//
//  Created by Christopher Aziz on 6/27/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var posts : [Post] = []

    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserService.posts(for: User.current) { (posts) in
            self.posts = posts
            self.tableView.reloadData()
        }
    }

}


// MARK: - UITableViewDataSource

extension HomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostImageCell", for: indexPath) as! PostImageCell
        
        let post = posts[indexPath.row]
        let imageURL = URL(string: post.imageURL)
//        cell.postImageView.kf.setImage(with: imageURL)
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        return post.imageHeight
    }
}
