//
//  JoinHouseholdViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 11/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class JoinHouseholdViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Outlets
	
    @IBOutlet weak var invitationCodeField: UITextField!
	
	// MARK: Fields
	
	let db = Firestore.firestore()
    
	// MARK: Lifecycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		invitationCodeField.delegate = self
		
		// Add blue border
		invitationCodeField.layer.borderColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).cgColor
		invitationCodeField.layer.borderWidth = 1.0
	}
	
	// MARK: Actions
    
    @IBAction func joinHouseholdAction(_ sender: Any) {
		let userId = UserDefaults.standard.string(forKey: StorageKeys.UserId)
		if userId != nil && !userId!.isEmpty {
			let invitationCode = invitationCodeField.text ?? ""
			if invitationCode.isEmpty || invitationCode.count < 8 {
				// Nothing entered, give error
				invalidInputError(alert: "")
			} else {
				// Valid code entered, try to join household
				joinHousehold(invitationCode: invitationCode, userId: userId!)
			}
		} else {
			// No user id saved, abort
			navigationController?.popViewController(animated: true)
		}
    }
	
	// MARK: Private methods
	
	func invalidInputError(alert: String) {
		invitationCodeField.layer.borderColor = UIColor.red.cgColor
		invitationCodeField.layer.borderWidth = 1.0
		
		if !alert.isEmpty {
			let alertController = UIAlertController(title: nil, message: alert, preferredStyle: UIAlertController.Style.alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alertController.addAction(alertAction)
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	func joinHousehold(invitationCode: String, userId: String) {
		db.collection(FireStoreConstants.CollectionPathInvites).document(invitationCode)
			.getDocument { (document, error) in
				if document != nil && document!.exists {
					// Get household linked to invite
					if let householdRef = document?.get(FireStoreConstants.FieldHousehold) as? DocumentReference {
						// Add household reference to user
						let userRef = self.db.collection(FireStoreConstants.CollectionPathUsers).document(userId)
						userRef.updateData([
							FireStoreConstants.FieldHousehold: householdRef
						]) { err in
							if let err = err {
								print("Error updating household field: \(err)")
							}
						}
						
						// Add user to household members
						let userData: [String: Any] = [
							FireStoreConstants.FieldColor: "0000FF", // TODO: Randomize color
							FireStoreConstants.FieldUserReference: userRef
						]
						
						householdRef.collection(FireStoreConstants.CollectionPathMembers)
						.document(userId).setData(userData) { err in
							if let err = err {
								print("Failed to add user as household member: \(err)")
							}
						}
						
						let userBalance: [String: Any] = [
							FireStoreConstants.FieldCurrentUserBalance: 0.0
						]
						
						self.db.collection(FireStoreConstants.CollectionPathUsers).document(userId).updateData(userBalance) { err in
							if let err = err {
								print("Error updating document: \(err)")
							} else {
								print("Document successfully updated")
							}
						}
						
						// Store household and go to household manager home
						UserDefaults.standard.set(householdRef.path, forKey: StorageKeys.HouseholdPath)
						self.performSegue(withIdentifier: "joinHousehold", sender: self)
					}
				} else {
					self.invalidInputError(alert: "Invalid invitation code.")
				}
		}
	}
	
	// MARK: UITextFieldDelegate methods
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// Limit the input to 8 characters; the size of an invitation code
		let characterCountLimit = 8;
		
		guard let text = textField.text else { return true }
		let count = text.count + string.count - range.length
		return count <= characterCountLimit
	}
}
