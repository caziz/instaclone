//
//  UserService.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/26/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

/* static network functions for firebase */

struct UserService {
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = [Constants.UserDefaults.username: username]

        // get ref from firUser
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        // set the username and call the block:
        ref.setValue(userAttrs) { (error, ref) in
            // if error, print desc and call completion with nil
            if let error = error {
                assertionFailure(error.localizedDescription)
                completion(nil)
                return
            }
            // otherwise get snapshot and initialize user and pass to completion
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }

    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
       
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(user)
        })
    }
    
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        // /posts/currentUID/snapshot
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] =
                snapshot
                    .reversed()
                    .flatMap {
                        guard let post = Post(snapshot: $0)
                            else { return nil }
                        
                        dispatchGroup.enter()
                        
                        // set isLiked member variable
                        LikeService.isPostLiked(post) { (isLiked) in
                            post.isLiked = isLiked
                            
                            dispatchGroup.leave()
                        }
                        
                        return post
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
            })
        })
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        // Create a DatabaseReference to read all users from the database.
        let ref = Database.database().reference().child("users")
        
        // Read the users node from the database.
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            // Take the snapshot and perform a few transformations. First, we convert all of the child DataSnapshot into User using our failable initializer. Next we filter out the current user object from the User array.
            let users =
                snapshot
                    .flatMap(User.init)
                    .filter { $0.uid != currentUser.uid }
            
            // Create a new DispatchGroup so that we can be notified when all asynchronous tasks are finished executing. We'll use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                // Make a request for each individual user to determine if the user is being followed by the current user.
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            
            // Run the completion block after all follow relationship data has returned.
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
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
