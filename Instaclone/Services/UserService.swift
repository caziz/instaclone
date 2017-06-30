//
//  UserService.swift
//  Makestagram
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
        // get post reference
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        // pull snapshot from reference
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let posts = snapshot.reversed().flatMap(Post.init)
            completion(posts)
        })
    }

}
