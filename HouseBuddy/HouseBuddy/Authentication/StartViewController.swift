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

class StartViewController: UIViewController, GIDSignInUIDelegate {

	//MARK: Fields
	@IBOutlet weak var logInBtn: UIButton!
	@IBOutlet weak var signUpBtn: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let user = Auth.auth().currentUser {
			// Store user id
			UserDefaults.standard.set(user.uid, forKey: StorageKeys.UserId)
			
			self.performSegue(withIdentifier: "alreadyLoggedIn", sender: self)
		}
		
		//Defining the Google Login Button
		GIDSignIn.sharedInstance().uiDelegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Disable back navigation
		navigationItem.hidesBackButton = true;
		navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
		navigationController!.interactivePopGestureRecognizer!.isEnabled = false;
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	// MARK: - Navigation
	@IBAction func logInAction(_ sender: Any) {
		if Auth.auth().currentUser == nil {
			self.performSegue(withIdentifier: "logInSegue", sender: self)
		}
	}
	
	@IBAction func signUpAction(_ sender: Any) {
		if Auth.auth().currentUser == nil {
			self.performSegue(withIdentifier: "signUpSegue", sender: self)
		}
	}
}
