//
//  StorageService.swift
//  Makestagram
//
//  Created by Christopher Aziz on 6/29/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import FirebaseStorage


struct StorageService {
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // convert image to data and reduce quality, otherwise return nil
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // put data in reference
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // if failure crash and return nil
            if let error = error {
                assertionFailure(error.localizedDescription)
                // is this redundant?
                return completion(nil)
            }
            
            // success: return the download URL for the image.
            completion(metadata?.downloadURL())
        })
    }
}


