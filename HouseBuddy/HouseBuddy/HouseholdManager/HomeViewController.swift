//
//  HomeViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    
	//MARK: Fields
	@IBOutlet weak var userNameLbl: UILabel!
	@IBOutlet weak var signOutBtn: UIButton!


	override func viewDidLoad() {
		super.viewDidLoad()
	}
    
    @IBAction func logOutAction(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			GIDSignIn.sharedInstance().signOut()
		} catch let signOutError as NSError {
			print ("Error signing out: %@", signOutError)
		}

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let initial = storyboard.instantiateInitialViewController()
		UIApplication.shared.keyWindow?.rootViewController = initial
    }
}
