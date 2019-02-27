//
//  InviteToHouseholdViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 13/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class InviteToHouseholdViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Fields
	
	let db = Firestore.firestore()
	var householdRef: DocumentReference?
	var listener: ListenerRegistration?
	
	var inviteCode: String = ""
	
	// MARK: Outlets
	
    @IBOutlet weak var invitationCodeField: UITextField!
	
	// MARK: Lifecycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		invitationCodeField.delegate = self

		// Add blue border
		invitationCodeField.layer.borderColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).cgColor
		invitationCodeField.layer.borderWidth = 1.0
		
		// Disable user interaction
		invitationCodeField.isUserInteractionEnabled = false
		
		// Set to old invitation code if it exists
		if let oldInviteCode = UserDefaults.standard.string(forKey: StorageKeys.InviteCode) {
			invitationCodeField.text = oldInviteCode
		}
		
		// Get current invite code, if it exists
		let householdPath = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath)
		householdRef = db.document(householdPath!)
		householdRef!.getDocument() { (document, err) in
			if let err = err {
				print("Failed to retrieve household invite code: \(err)")
			} else if document != nil && document!.exists {
				if let inviteCode = document?.get(FireStoreConstants.FieldInviteCode) as? String {
					// Set and store invite code if it exists
					self.inviteCode = inviteCode
					self.invitationCodeField.text = inviteCode
					UserDefaults.standard.set(inviteCode, forKey: StorageKeys.InviteCode)
				} else {
					// No invite code stored, generate and store a new code
					self.generateNewInviteCode()
				}
			}
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		addListener()
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		listener?.remove()
	}
	
	// MARK: Private methods
	
	func generateNewInviteCode() {
		var existingInvites = [String]()
		let invitesCollection = db.collection(FireStoreConstants.CollectionPathInvites)
		
		invitesCollection.getDocuments() { (querySnapshot, err) in
			if let err = err {
				print("Failed to retrieve invites: \(err)")
			} else {
				// Add all existing invites to list
				for document in querySnapshot!.documents {
					existingInvites.append(document.documentID)
				}
				
				// Check if there is an old invite code
				if (existingInvites.contains(self.inviteCode)) {
					// Delete old invite code from invites collection
					invitesCollection.document(self.inviteCode).delete() { err in
						if let err = err {
							print("Failed to delete invite: \(err)")
						}
					}
				}
				
				// Create a new code if the inviteCode already exists
				repeat {
					self.inviteCode = self.randomString()
				} while (existingInvites.contains(self.inviteCode))
				
				// Update invite code in household document
				self.householdRef!.updateData([
					FireStoreConstants.FieldInviteCode: self.inviteCode
				]) { err in
					if let err = err {
						print("Failed to add invite code to household: \(err)")
					}
				}
				
				// Add new invite code to invites collection
				invitesCollection.document(self.inviteCode).setData([
					FireStoreConstants.FieldHousehold: self.householdRef!
				]) { err in
					if let err = err {
						print("Failed to add invite: \(err)")
					}
				}
			}
		}
	}
	
	// Auxiliary function that creates a random, human readable string
	func randomString() -> String {
		let AB = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
		var output: String = ""
		
		for _ in 0 ..< 8 {
			output.append(AB.randomElement()!)
		}
		
		return output
	}
	
	func addListener() {
		listener = householdRef!.addSnapshotListener { (documentSnapshot, error) in
			guard documentSnapshot != nil else {
				print("Error fetching household: \(error!)")
				return
			}
			
			if documentSnapshot!.exists {
				if let inviteCode = documentSnapshot?.get(FireStoreConstants.FieldInviteCode) as? String {
					// Set and store invite code if it exists
					self.inviteCode = inviteCode
					self.invitationCodeField.text = inviteCode
					UserDefaults.standard.set(inviteCode, forKey: StorageKeys.InviteCode)
				}
			}
		}
	}

	// MARK: Actions
	
	@IBAction func menuAction(_ sender: Any) {
		let appDel = UIApplication.shared.delegate as! AppDelegate
		appDel.drawerController.setDrawerState(.opened, animated: true)
	}
	
    @IBAction func renewInviteCode(_ sender: Any) {
		generateNewInviteCode()
    }
}
