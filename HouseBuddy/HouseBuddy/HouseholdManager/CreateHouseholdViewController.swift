//
//  CreateHouseholdViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 13/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateHouseholdViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Outlets
	
    @IBOutlet weak var householdNameField: UITextField!
	
	// MARK: Attributes
	
	let db = Firestore.firestore()
	
	// MARK: Lifecycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		householdNameField.delegate = self
    }
	
	// MARK: Private methods
	
	func invalidInputError() {
		householdNameField.layer.borderColor = UIColor.red.cgColor
		householdNameField.layer.borderWidth = 1.0
	}
	
	func createHousehold(householdName: String, userId: String) {
		// Create new household with name
		var householdRef: DocumentReference? = nil
		householdRef = db.collection(FireStoreConstants.CollectionPathHouseholds).addDocument(data: [
			FireStoreConstants.FieldName: householdName
		]) { err in
			if let err = err {
				print("Failed to add household: \(err)")
			} else {
				// Add household reference to user
				let userRef = self.db.collection(FireStoreConstants.CollectionPathUsers).document(userId)
				print("Household with id \(householdRef!.documentID) added to user")
				userRef.updateData([
					FireStoreConstants.FieldHousehold: householdRef!.documentID
				]) { err in
					if let err = err {
						print("Failed to add household to user: \(err)")
					}
				}
				
				// Add user to household members
				let userData: [String: Any] = [
					FireStoreConstants.FieldColor: "0000FF", // TODO: Randomize color
					FireStoreConstants.FieldUserReference: userRef
				]
				
				householdRef!.collection(FireStoreConstants.CollectionPathMembers)
					.document(userId).setData(userData) { err in
						if let err = err {
							print("Failed to add user as household member: \(err)")
						}
				}
				
				// Store household and go to household manager home
				UserDefaults.standard.set(householdRef!.path, forKey: StorageKeys.HouseholdPath)
				self.performSegue(withIdentifier: "createHousehold", sender: self)
			}
		}
	}
	
	// MARK: Actions
	
    @IBAction func createHouseholdAction(_ sender: Any) {
		let userId = UserDefaults.standard.string(forKey: StorageKeys.UserId)
		if userId != nil && !userId!.isEmpty {
			let householdName = householdNameField.text ?? ""
			if householdName.isEmpty {
				// Nothing entered, give error
				invalidInputError()
			} else {
				// Valid name entered, try to create household
				createHousehold(householdName: householdName, userId: userId!)
			}
		} else {
			// No user id saved, abort
			navigationController?.popViewController(animated: true)
		}
    }
    
}
