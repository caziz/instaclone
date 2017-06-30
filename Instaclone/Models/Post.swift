//
//  Post.swift
//  Makestagram
//
//  Created by Christopher Aziz on 6/29/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
    
    // MARK: - Properties
    
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo]
    }
    // MARK: - Init

    init(imageURL: String, imageHeight: CGFloat) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let imageURL = dict["image_url"] as? String,
            let imageHeight = dict["image_height"] as? CGFloat,
            let createdAgo = dict["created_at"] as? TimeInterval
            else { return nil }
        
        self.key = snapshot.key
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
    }
    
    // MARK: - Class Methods
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        // create new post in database
    }
    
}


