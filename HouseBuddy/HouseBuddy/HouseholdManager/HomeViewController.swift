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
	
	let db = Firestore.firestore()

	// MARK: Lifecycle methods
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: Actions
	
    @IBAction func leaveHousehold(_ sender: Any) {
		let alert = UIAlertController(title: "Leave household", message: "Are you sure you want to leave this household?", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
			// Initialize FireStore references
			let userId = UserDefaults.standard.string(forKey: StorageKeys.UserId)
			let userRef = self.db.collection(FireStoreConstants.CollectionPathUsers).document(userId!)
			let householdPath = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath)
			let householdRef = self.db.document(householdPath!)
			
			// Delete user from household's members
			householdRef.collection(FireStoreConstants.CollectionPathMembers).document(userId!).delete() { err in
				if let err = err {
					print("Error deleting user from household: \(err)")
				}
			}
			
			// Delete household reference from user
			userRef.updateData([
				FireStoreConstants.FieldHousehold: FieldValue.delete()
			]) { err in
				if let err = err {
					print("Error deleting household from user: \(err)")
				}
			}
			
			// Delete household if it's empty
			householdRef.collection(FireStoreConstants.CollectionPathMembers).getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Failed to retrieve household \(err)")
				} else {
					// Household has no more members, check if there is still an invite code
					if querySnapshot != nil && querySnapshot!.isEmpty {
						householdRef.getDocument() { (document, err) in
							if let document = document {
								if document.exists {
									if let inviteCode = document.get(FireStoreConstants.FieldInviteCode) as? String {
										// Delete household's invite code if it exists
										self.db.collection(FireStoreConstants.CollectionPathInvites).document(inviteCode).delete() { err in
											if let err = err {
												print("Failed to delete household invite code: \(err)")
											}
										}
									}
								}
							}
						}
						
						// Delete all household collections (by deleting all documents in the collections)
						for collectionPath in FireStoreConstants.HouseholdCollectionPaths {
							householdRef.collection(collectionPath).getDocuments() { (querySnapshot, err) in
								if let err = err {
									print("Failed to retrieve collection \(collectionPath): \(err)")
								} else {
									for document in querySnapshot!.documents {
										document.reference.delete() { err in
											if let err = err {
												print("Failed to delete document in \(collectionPath): \(err)")
											}
										}
									}
								}
							}
						}

						// Delete household
						householdRef.delete() { err in
							if let err = err {
								print("Failed to delete empty household: \(err)")
							}
						}
					}
				}
			}
			
			// Reset stored household path
			UserDefaults.standard.set("", forKey: StorageKeys.HouseholdPath)
			
			// Go to no household view
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noHouseholdVC") as! NoHouseholdViewController
			self.navigationController?.pushViewController(vc, animated: true)
		}))
		
		alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
		
		self.present(alert, animated: true)
	}
	
	@IBAction func logOutAction(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			GIDSignIn.sharedInstance().signOut()
			
			// Reset stored household path
			UserDefaults.standard.set("", forKey: StorageKeys.HouseholdPath)
		} catch let signOutError as NSError {
			print ("Error signing out: %@", signOutError)
		}
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let initial = storyboard.instantiateInitialViewController()
		UIApplication.shared.keyWindow?.rootViewController = initial
	}
}
