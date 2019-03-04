//
//  ShoppingListTableViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ShoppingListTableViewController: UITableViewController {
	
	// MARK: - Fields
	private var shoppingItems: Array<ShoppingItem> = []
	let db = Firestore.firestore()
	private var listener: ListenerRegistration?
	private var shoppingListRef: CollectionReference?
	var activityIndicatorView: UIActivityIndicatorView!
	lazy var refreshCommand: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action:
			#selector(ShoppingListTableViewController.handleRefresh(_:)),
								 for: UIControl.Event.valueChanged)
		refreshControl.tintColor = UIColor.blue
		
		return refreshControl
	}()
	
	//MARK: - View Handling
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.refreshControl = refreshCommand
		
		self.tableView.addSubview(self.refreshCommand)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Hide the NavBar on appearing
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillAppear(animated)
		
		self.becomeFirstResponder()
		
		if (shoppingItems.isEmpty) {
			activityIndicatorView = UIActivityIndicatorView(style: .gray)
			tableView.backgroundView = activityIndicatorView
			activityIndicatorView.startAnimating()
			
		}
		handleDBData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// Show the NavBar on disappearing
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		self.resignFirstResponder()
	}
	
	//MARK: - Refreshing of the data
	@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
		let alert = UIAlertController(title: "Remove bought items", message: "Are you sure you want to remove all bought items? This cannot be undone.", preferredStyle: UIAlertController.Style.alert)
		
		refreshCommand.endRefreshing()
		self.tableView.reloadData()
		
		alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
			self.removeBoughtItems()
			}))
		
		alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	// MARK: - Firestore functions
	fileprivate func handleDBData() {
		if let user = Auth.auth().currentUser {
			let userId = user.uid
			let userRef = db.collection(FireStoreConstants.CollectionPathUsers).document(userId)
			
			userRef.getDocument { (document, error) in
				if let document = document, document.exists {
					let householdRef = document.get(FireStoreConstants.FieldHousehold) as! DocumentReference
					self.shoppingListRef = householdRef.collection(FireStoreConstants.CollectionPathShoppingList)
					
					self.shoppingListRef!.getDocuments() { (querySnapshot, err) in
						if let err = err {
							print("Error getting documents: \(err)")
						} else {
							if !querySnapshot!.documents.isEmpty {
								self.listener = self.shoppingListRef!.order(by: "last_modified", descending: false).addSnapshotListener { querySnapshot, error in
									guard let documents = querySnapshot?.documents else {
										print("Error fetching documents: \(error!)")
										return
									}
									self.shoppingItems.removeAll()
									for document in documents {
										let name: String = document.get("item") as! String
										let bought: Bool = document.get("bought") as! Bool
										self.shoppingItems.append(ShoppingItem(name: name, bought: bought, itemID: document.documentID))
										print("\(document.documentID) => \(document.data())")
									}
									self.activityIndicatorView.stopAnimating()
									self.tableView.reloadData()
								}
							} else {
								self.activityIndicatorView.stopAnimating()
								print("Document does not exist")
							}
						}
					}
				}
			}
		} else {
			print("No user signed in.")
		}
	}
	
	func removeBoughtItems() -> Void {
		if let user = Auth.auth().currentUser {
			let userId = user.uid
			let userRef = db.collection(FireStoreConstants.CollectionPathUsers).document(userId)
			userRef.getDocument { (document, error) in
				if let document = document, document.exists {
					let householdRef = document.get(FireStoreConstants.FieldHousehold) as! DocumentReference
					self.shoppingListRef = householdRef.collection(FireStoreConstants.CollectionPathShoppingList)
					
					self.shoppingListRef!.getDocuments() { (querySnapshot, err) in
						if let err = err {
							print("Error getting shopping list documents: \(err)")
						} else {
							for document in querySnapshot!.documents {
								let bought: Bool = document.get("bought") as! Bool
								let name: String = document.get("item") as! String
								
								if (bought) {
									self.shoppingListRef?.document(document.documentID).delete() { err in
										if let err = err {
											print("Error removing document \(name): \(err)")
										} else {
											print("\(name) successfully removed!")
										}
									}
								}
							}
						}
					}
				}
			}
		} else {
			print("No user signed in.")
		}
		
		self.tableView.reloadData()
		refreshCommand.endRefreshing()
	}
	
	deinit {
		if listener != nil {
			listener!.remove()
		}
	}
	
	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
		// TODO: Split items into done and not done?
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return shoppingItems.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "shoppingItemCell"
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShoppingListTableViewCell  else {
			fatalError("The dequeued cell is not an instance of ShoppingListTableViewCell.")
		}
		
		let item = shoppingItems[indexPath.row]
		
		cell.nameLabel.text = item.name
		
		cell.backgroundColor = (item.bought ? UIColor.green : UIColor.white)
		
		return cell
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the row from the data source
			let selectedTask = shoppingItems[indexPath.row]
			
			shoppingItems.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
			
			shoppingListRef!.document(selectedTask.itemID!).delete() { err in
				if let err = err {
					print("Error removing document: \(err)")
				} else {
					print("Document successfully removed!")
				}
			}
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
	
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let closeAction = UIContextualAction(style: .normal, title:  "Bought", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
			print("Changed bought state")
			let selectedTask = self.shoppingItems[indexPath.row]
			
			let currentState = !selectedTask.bought
			self.shoppingItems[indexPath.row].bought = currentState
			self.tableView.cellForRow(at: indexPath)?.backgroundColor = (currentState ? UIColor.green : UIColor.white)
			
			
			self.shoppingListRef!.document(selectedTask.itemID!).updateData([
				"bought": currentState
			]) { err in
				if let err = err {
					print("Error updating document: \(err)")
				} else {
					print("Document successfully updated")
				}
			}
			
			success(true)
		})
		closeAction.image = UIImage(named: "tick")
		closeAction.backgroundColor = .blue
		
		return UISwipeActionsConfiguration(actions: [closeAction])
		
	}
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			print("Shake it baby, shake it")
		}
	}
	
	// MARK: - Navigation
	@IBAction func unwindToShoppingList(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? EditShoppingItemViewController, let shopItem = sourceViewController.shoppingItem {
			
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				
				// Update an existing meal.
				shoppingItems[selectedIndexPath.row] = shopItem
				tableView.reloadRows(at: [selectedIndexPath], with: .none)
				
				shoppingListRef?.document(shopItem.itemID!).updateData([
					"item": shopItem.name,
					"bought": shopItem.bought,
					"last_modified": FieldValue.serverTimestamp()
				]) { err in
					if let err = err {
						print("Error updating document: \(err)")
					} else {
						print("Document successfully updated")
					}
				}
			} else {
				
				// Add a new shoppingItem.
				let newIndexPath = IndexPath(row: shoppingItems.count, section: 0)
				
				var ref: DocumentReference? = nil
				ref = shoppingListRef?.addDocument(data: [
					"item": shopItem.name,
					"bought": false,
					"last_modified": FieldValue.serverTimestamp()
				]) { err in
					if let err = err {
						print("Error adding document: \(err)")
					} else {
						print("Document added with ID: \(ref!.documentID)")
					}
				}
				shopItem.itemID = ref!.documentID
				
				shoppingItems.append(shopItem)
				tableView.insertRows(at: [newIndexPath], with: .automatic)
			}
		}
	}
	
	
	// Prepares for the segue to take place
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		switch (segue.identifier ?? "") {
		case "addNewShoppingItemSegue":
			os_log("Adding a new shopping item.", log: OSLog.default, type: .debug)
			
		case "showShoppingItemSegue":
			guard let showShoppingItemViewController = segue.destination as? ShowShoppingItemViewController else {
				fatalError("Unexpected destination: \(segue.destination)")
			}
			
			guard let selectedShoppingItemCell = sender as? ShoppingListTableViewCell else {
				fatalError("Unexpected sender: \(sender ?? "Undeclared sender")")
			}
			
			guard let indexPath = tableView.indexPath(for: selectedShoppingItemCell) else {
				fatalError("The selected cell is not being displayed by the table")
			}
			
			let selectedShoppingItem = shoppingItems[indexPath.row]
			showShoppingItemViewController.shoppingItem = selectedShoppingItem
			
		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No segue defined")")
		}
	}
    
    // MARK: Actions
    @IBAction func menuAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.drawerController.setDrawerState(.opened, animated: true)
    }
	
}
