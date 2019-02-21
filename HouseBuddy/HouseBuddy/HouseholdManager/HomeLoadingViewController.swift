//
//  HouseholdLoadingViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 08/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class HomeLoadingViewController: UIViewController {
    
    // MARK: Attributes
	
	let db = Firestore.firestore()
	var userRef: DocumentReference?
	var householdRef: DocumentReference?
	
	var userId: String?
	var userEmail : String?
	var userName : String?
	var userSurname : String?

	// MARK: Lifecycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
    }
	
	override func viewDidAppear(_ animated: Bool) {
		if userHasHousehold() {
			userId = UserDefaults.standard.string(forKey: StorageKeys.UserId)
			userRef = db.collection(FireStoreConstants.CollectionPathUsers).document(userId!)
			
			let householdPath = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath)
			householdRef = db.document(householdPath!)
			
			self.performSegue(withIdentifier: "loadingToHome", sender: self)
		} else {
			fetchUserData()
		}
	}
	
	// MARK: Private methods
	
	func userHasHousehold() -> Bool {
		// Checks if user has a stored household
		let householdPath = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath) ?? ""
		return !householdPath.isEmpty
	}
	
	func storeHousehold(householdPath: String) {
		householdRef = db.document(householdPath)
		
		// Store household path on device
		UserDefaults.standard.set(householdPath, forKey: StorageKeys.HouseholdPath)
	}
	
	func saveUserInfo(userId: String?, userEmail: String?, firstName: String?, lastName: String?) {
		if userId != nil {
			UserDefaults.standard.set(userId, forKey: StorageKeys.UserId)
		}
		
		if userEmail != nil {
			UserDefaults.standard.set(userEmail, forKey: StorageKeys.UserEmail)
		}
		
		if firstName != nil {
			UserDefaults.standard.set(firstName, forKey: StorageKeys.FirstName)
		}
		
		if lastName != nil {
			UserDefaults.standard.set(lastName, forKey: StorageKeys.LastName)
		}
	}
	
	func fetchUserData() {
		guard let user = Auth.auth().currentUser else {
			print("No user signed in")
			return
		}
		
		self.userId = user.uid
		if self.userId != nil {
			userRef = db.collection(FireStoreConstants.CollectionPathUsers).document(userId!)
			
			userRef!.getDocument { (document, error) in
				if let document = document {
					// Check if user is already registered in the database
					if document.exists {
						// Check if user has household
						if let householdRef = document.get(FireStoreConstants.FieldHousehold) as? DocumentReference {
							self.storeHousehold(householdPath: householdRef.path)
							self.performSegue(withIdentifier: "loadingToHome", sender: self)
						} else {
							// User is an existing user without a household
							self.performSegue(withIdentifier: "noHousehold", sender: self)
						}
					} else {
						// User is a new user
						if (self.userEmail != nil) && (self.userName != nil) && (self.userSurname != nil) {
							// Save user information to device
							self.saveUserInfo(userId: self.userId!, userEmail: self.userEmail,
											  firstName: self.userName, lastName: self.userSurname)
							
							let userData: [String: Any] = [
								"email": self.userEmail!,
								"first_name": self.userName!,
								"last_name": self.userSurname!
							]
							
							self.db.collection(FireStoreConstants.CollectionPathUsers).document(self.userId!)
								.setData(userData) { err in
								if let err = err {
									print("Error adding user document: \(err)")
								} else {
									self.performSegue(withIdentifier: "noHousehold", sender: self)
									print("User document added with ID: \(self.userId!)")
								}
							}
						} else {
							// User is logged in without being registered, show registration form for email, first name and last name
						}
					}
				}
			}
		}
	}
}
