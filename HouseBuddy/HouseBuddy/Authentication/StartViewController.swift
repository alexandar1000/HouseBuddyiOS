//
//  StartViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

class StartViewController: UIViewController, GIDSignInUIDelegate{
	
	

    //MARK: Fields
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
			  if Auth.auth().currentUser != nil {
			  	self.performSegue(withIdentifier: "alreadyLoggedIn", sender: nil)
			  }
			
			//Defining the Google Login Button
			GIDSignIn.sharedInstance().uiDelegate = self
					
			// TODO(developer) Configure the sign-in button look/feel
			// ...
    }
	
		// MARK: - Navigation
    @IBAction func logInAction(_ sender: Any) {
			if Auth.auth().currentUser == nil {
				self.performSegue(withIdentifier: "logInSegue",
                          sender: self)
			}
    }
    
    @IBAction func signUpAction(_ sender: Any) {
			if Auth.auth().currentUser == nil {
				self.performSegue(withIdentifier: "signUpSegue",
                          sender: self)
			}
    }
}
