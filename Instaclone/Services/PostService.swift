//
//  PostService.swift
//  Makestagram
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
        // user's UID needed
        let currentUser = User.current
        // init post with parameters
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        // get dictionary version of post
        let dict = post.dictValue
        // generate reference within uid
        let postRef = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
        // store post
        postRef.updateChildValues(dict)
    }
}
