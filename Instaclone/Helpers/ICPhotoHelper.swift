//
//  ICPhotoHelper.swift
//  Makestagram
//
//  Created by Christopher Aziz on 6/28/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit

class ICPhotoHelper: NSObject {
    // MARK: - Properties
    
    // handle image
    var completionHandler: ((UIImage) -> Void)?
    
    // MARK: - Helper Methods
    
    func presentActionSheet(from viewController: UIViewController) {
        // Initialize a new UIAlertController of type actionSheet. UIAlertController can be used to present different types of alerts. An action sheet is a popup that will be displayed at the bottom edge of the screen.
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        // Check if the current device has a camera available. The simulator doesn't have a camera and won't execute the if clause
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Create a new UIAlertAction. Each UIAlertAction represents an action on the UIAlertController. As part of the UIAlertAction initializer, you can provide a title, style, and handler that will execute when the action is selected.
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { action in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            
            // Add the action to the alertController instance we created.
            alertController.addAction(capturePhotoAction)
        }
        
        // Repeat for the user's photo library.
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { action in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            alertController.addAction(uploadAction)
        }
        
        // Add a cancel action to allow an user to close the UIAlertController action sheet. Notice that the style is .cancel instead of .default.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the UIAlertController from our UIViewController. Remember, we must pass in a reference from the view controller presenting the alert controller for this method to properly present the UIAlertController.
        viewController.present(alertController, animated: true)
    }
    
        func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        
        // We create a new instance of UIImagePickerController. This object will present a native UI component that will allow the user to take a photo from the camera or choose an existing image from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // We set the sourceType to determine whether the UIImagePickerController will activate the camera and display a photo taking overlay or show the user's photo library. The sourceType is specified by the argument passed into the function.
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self

        viewController.present(imagePickerController, animated: true)
    }
}

extension ICPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // called when image is selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            completionHandler?(selectedImage)
        }
        
        picker.dismiss(animated: true)
    }
    
    // called when image picker is canceled
    // since we are delegate, we become responsible for dismissing
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
