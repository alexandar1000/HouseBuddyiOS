//
//  DrawerViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 23/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import FirebaseFirestore

class DrawerViewController: UITableViewController {

    // MARK: Outlets
    
    @IBOutlet var menuTable: UITableView!
	
	// MARK: Fields
	
	let db = Firestore.firestore()
	let drawerController = (UIApplication.shared.delegate as! AppDelegate).drawerController
	let storyboardMain = UIStoryboard(name: "Main", bundle: nil)
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Remove unneeded cell seperators
        tableView.tableFooterView = UIView()
    }
	
	// Private methods
	
	func navigateToScreen(withIdentifier id: String) {
		let viewController = storyboardMain.instantiateViewController(withIdentifier: id)
		let navigation = UINavigationController(rootViewController: viewController)
		drawerController.mainViewController = navigation
		
		// Hide drawer
		drawerController.setDrawerState(.closed, animated: true)
	}
    
    // MARK: Actions

    @IBAction func homeAction(_ sender: Any) {
		navigateToScreen(withIdentifier: "Home")
    }
	
    @IBAction func todoListAction(_ sender: Any) {
		navigateToScreen(withIdentifier: "TodoList")
    }
    
    @IBAction func shoppingListAction(_ sender: Any) {
		navigateToScreen(withIdentifier: "ShoppingList")
    }
	
    @IBAction func expenseTrackerAction(_ sender: Any) {
		navigateToScreen(withIdentifier: "ExpenseTracker")
    }
	
    @IBAction func inviteToHouseholdAction(_ sender: Any) {
		navigateToScreen(withIdentifier: "Invite")
    }
    
    @IBAction func leaveHouseholdAction(_ sender: Any) {
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
							if let err = err {
								print("Failed to retrieve household invite code: \(err)")
							} else if document != nil && document!.exists {
								if let inviteCode = document?.get(FireStoreConstants.FieldInviteCode) as? String {
									// Delete household's invite code if it exists
									self.db.collection(FireStoreConstants.CollectionPathInvites).document(inviteCode).delete() { err in
										if let err = err {
											print("Failed to delete household invite code: \(err)")
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
				}
			}
			
			// Reset stored household path
			UserDefaults.standard.set("", forKey: StorageKeys.HouseholdPath)
			
			// Go to no household view
			self.navigateToScreen(withIdentifier: "noHouseholdVC")
			
			// Disable drawer
			self.drawerController.screenEdgePanGestureEnabled = false
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
			return
		}
		
		// Navigate to log in screen
		navigateToScreen(withIdentifier: "Start")
		
		// Disable drawer
		drawerController.screenEdgePanGestureEnabled = false
    }
}
