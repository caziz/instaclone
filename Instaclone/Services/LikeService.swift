//
//  LikeService.swift
//  Instaclone
//
//  Created by Christopher Aziz on 7/2/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct LikeService {
    static func create(for post: Post, success: @escaping (Bool) -> Void) {
        // Each post that we like must have a key. We check the post has a key and return false if there is not.
        guard let key = post.key else {
            return success(false)
        }
        
        // We create a reference to the current user's UID. We'll use this soon to build the location of where we'll store the data for liking the post.
        let currentUID = User.current.uid

        // like post by setting current uid to true
        // set "postLikes"/post/currentUID/true
        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
        likesRef.setValue(true) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            // update like count
            // "posts"/post.poster/post/"like_count"
            let likeCountRef = Database.database().reference().child("posts").child(post.poster.uid).child(key).child("like_count")
            
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    success(true)
                }
            })
        }
    }
    static func delete(for post: Post, success: @escaping (Bool) -> Void) {
        guard let key = post.key else {
            return success(false)
        }
        
        let currentUID = User.current.uid
        
        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
        likesRef.setValue(nil) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            // update like count
            let likeCountRef = Database.database().reference().child("posts").child(post.poster.uid).child(key).child("like_count")
            
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount - 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    success(true)
                }
            })
        }
    }
    
    static func isPostLiked(_ post: Post, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        guard let postKey = post.key else {
            assertionFailure("Error: post must have key.")
            return completion(false)
        }
        
        // /postLikes/postKey/currentUID
        let likesRef = Database.database().reference().child("postLikes").child(postKey)
        likesRef.queryEqual(toValue: nil, childKey: User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                // post is liked by current user
                completion(true)
            } else {
                // post is not liked
                completion(false)
            }
        })
    }
    
    static func setIsLiked(_ isLiked: Bool, for post: Post, success: @escaping (Bool) -> Void) {
        if isLiked {
            create(for: post, success: success)
        } else {
            delete(for: post, success: success)
        }
    }
}



