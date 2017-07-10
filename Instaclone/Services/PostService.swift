//
//  PostService.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/29/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    static func create(for image: UIImage) {
        let imageRef = Storage.storage().reference().child("test_image.jpg")
        // upload image to firebase storage
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            // save url to image in database
            create(forURLString: urlString, aspectHeight: aspectHeight)
        }
    }
    
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        let currentUser = User.current
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        // We create references to the important locations that we're planning to write data.
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // Use our class method to get an array of all of our follower UIDs
        UserService.followers(for: currentUser) { (followerUIDs) in
            // We construct a timeline JSON object where we store our current user's uid. We need to do this because when we fetch a timeline for a given user, we'll need the uid of the post in order to read the post from the Post subtree.
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // We create a mutable dictionary that will store all of the data we want to write to our database. We initialize it by writing the current timeline dictionary to our own timeline because our own uid will be excluded from our follower UIDs.
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // We create a mutable dictionary that will store all of the data we want to write to our database. We initialize it by writing the current timeline dictionary to our own timeline because our own uid will be excluded from our follower UIDs.
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // We make sure to write the post we are trying to create.
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // We write our multi-location update to our database.
            rootRef.updateChildValues(updatedData)
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
    
    static func timeline(completion: @escaping ([Post]) -> Void) {
        let currentUser = User.current
        
        let timelineRef = Database.database().reference().child("timeline").child(currentUser.uid)
        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts.reversed())
            })
        })
    }
}
