//
//  Storyboard+Utility.swift
//  Makestagram
//
//  Created by Christopher Aziz on 6/27/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    enum ICType: String {
        case main
        case login
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: ICType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    static func initialViewController(for type: ICType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
        }
        return initialViewController
    }
}
