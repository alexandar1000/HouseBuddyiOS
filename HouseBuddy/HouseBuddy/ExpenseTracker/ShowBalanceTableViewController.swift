//
//  ShowBalanceTableViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 02/03/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase

class ShowBalanceTableViewController: UITableViewController {
	
	private var names: [String] = []
	private var balances: [Double] = []
	private var db = Firestore.firestore()
	private var activityIndicatorView: UIActivityIndicatorView!
	var isSettling: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if (balances.isEmpty) {
			activityIndicatorView = UIActivityIndicatorView(style: .gray)
			tableView.backgroundView = activityIndicatorView
			activityIndicatorView.startAnimating()
			
		}
		
		handleDBData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		if isSettling {
			let householdPath: String = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath) ?? ""
			db.document(householdPath).collection(FireStoreConstants.CollectionPathMembers).getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error getting documents: \(err)")
				} else {
					for document in querySnapshot!.documents {
						let userRef = document.get("user_reference") as! DocumentReference
						userRef.updateData([
							"balance": 0
						]) { err in
							if let err = err {
								print("Error updating document: \(err)")
							} else {
								print("Document successfully updated")
							}
						}
					}
				}
			}
			db.document(householdPath).collection(FireStoreConstants.CollectionPathExpenseTracker).getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error getting documents: \(err)")
				} else {
					for document in querySnapshot!.documents {
						let expenseRef = document.documentID
						self.db.document(householdPath).collection(FireStoreConstants.CollectionPathExpenseTracker).document(expenseRef).delete() { err in
							if let err = err {
								print("Error removing document: \(err)")
							} else {
								print("Document successfully removed!")
							}
						}
					}
				}
			}
		}
	}
	
	// MARK: - Firestore functions
	fileprivate func handleDBData() {
		let householdPath: String = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath) ?? ""
		db.document(householdPath).collection(FireStoreConstants.CollectionPathMembers).getDocuments() { (querySnapshot, err) in
			if let err = err {
				print("Error getting documents: \(err)")
			} else {
				var userName: String = ""
				var userBalance: Double = 0
				for document in querySnapshot!.documents {
					let userRef = document.get("user_reference") as! DocumentReference
					userRef.getDocument { (currentUsersDocument, error) in
						if let currentUsersDocument = currentUsersDocument, currentUsersDocument.exists {
							let name = currentUsersDocument.get("first_name") as! String
							let surname = currentUsersDocument.get("last_name") as! String
							userName = "\(name) \(surname)"
							userBalance = currentUsersDocument.get("balance") as! Double
							self.names.append(userName)
							self.balances.append(userBalance)
							self.activityIndicatorView.stopAnimating()
							self.tableView.reloadData()
						} else {
							print("Document does not exist")
						}
					}
				}
			}
		}
		self.activityIndicatorView.stopAnimating()
		self.tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "balanceCell", for: indexPath) as? ShowBalanceTableViewCell else {
			fatalError("The dequeued cell is not an instance of ShowBalanceTableViewCell.")
		}

		cell.nameLbl.text = names[indexPath.row]
		cell.balanceLbl.text = "\(balances[indexPath.row])"

        return cell
    }
}
