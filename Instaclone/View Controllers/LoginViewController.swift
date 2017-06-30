//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Christopher Aziz on 6/26/17.
//  Copyright © 2017 Christopher Aziz. All rights reserved.
//

import UIKit
import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase


typealias FIRUser = FirebaseAuth.User



class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonTapped(_ sender: Any) {
        // access the FUIAuth default auth UI singleton
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        // set FUIAuth's singleton delegate
        authUI.delegate = self
        
        // present the auth view controller
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        
        // TODO do I need these checks?
        if let error = error {
            assertionFailure("Error signing in: " + error.localizedDescription)
            return
        }
        guard let user = user
            else { return }
        
        UserService.show(forUID: user.uid) { (user) in
            if let user = user {
                // handle existing user
                print("Welcome back, \(user.username).")
                User.setCurrent(user, writeToUserDefaults: true)
                
                // goto main storyboard
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                
            } else {
                // handle new user
                print("New user!")
                
                // segue to create username
                self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
            }
        }
    }
}
