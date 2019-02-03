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
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController {
    
	//MARK: Fields
	@IBOutlet weak var userNameLbl: UILabel!
	@IBOutlet weak var signOutBtn: UIButton!

	var userEmail : String?
	var userName : String?
	var userSurname : String?

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		checkAndAddToDatabase()
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
	
	func checkAndAddToDatabase() {
		let db = Firestore.firestore()
		
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
		
		if (userEmail != nil) && (userName != nil) && (userSurname != nil) {
			if let user = Auth.auth().currentUser {
				let uid = user.uid
				let docRef = db.collection("users").document(uid)
				
				docRef.getDocument { (document, error) in
					if let document = document {
						if !document.exists {
							print("First Sign Up. Adding the user to the database")
							let userData: [String: Any] = [
								"email": self.userEmail!,
								"first_name": self.userName!,
								"last_name": self.userSurname!
							]
							db.collection("users").document(uid).setData(userData) { err in
								if let err = err {
									print("Error adding user document: \(err)")
								} else {
									print("User document added with ID: \(uid)")
								}
							}
						} else {
							print("User with the UserID \(uid) already added")
						}
					}
				}
			}
		}
	}
}
