//
//  UITabBarController.swift
//  Instaclone
//
//  Created by Christopher Aziz on 6/27/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Properties
    
    let photoHelper = ICPhotoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoHelper.completionHandler = { image in
            // handle image
            PostService.create(for: image)
        }
        
        delegate = self
        tabBar.unselectedItemTintColor = .black
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 1 {
            photoHelper.presentActionSheet(from: self)
            return false
        } else {
            return true
        }
    }
}
