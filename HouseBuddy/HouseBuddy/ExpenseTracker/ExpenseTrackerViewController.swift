//
//  ExpenseTrackerViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 27/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ExpenseTrackerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Fields
	@IBOutlet weak var tableView: UITableView!
	private var expenses: [ExpenseEntry] = []
	let db = Firestore.firestore()
	private var listener: ListenerRegistration?
	private var expensesRef: CollectionReference?
	var df: DateFormatter = DateFormatter()
	var activityIndicatorView: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		df.dateFormat = "dd.MM.yyyy"
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
		//add border to the tableView
		tableView.layer.masksToBounds = true
		tableView.layer.borderColor = UIColor( red: 0/255, green: 0/255, blue:0/255, alpha: 1.0 ).cgColor
		tableView.layer.borderWidth = 0.7
		
		tableView.dataSource = self
        tableView.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		// Hide the NavBar on appearing
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillAppear(animated)
		
		if (expenses.isEmpty) {
			activityIndicatorView = UIActivityIndicatorView(style: .gray)
			tableView.backgroundView = activityIndicatorView
			activityIndicatorView.startAnimating()
			
		}
		
		handleDBData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		// Show the NavBar on disappearing
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	// MARK: - Firestore functions
	fileprivate func handleDBData() {
		
		// TODO: Retrieving household id should be moved to HouseHoldManager class where it's put in the device storage..
		if let user = Auth.auth().currentUser {
			let userId = user.uid
			let userRef = db.collection(FireStoreConstants.CollectionPathUsers).document(userId)
			
			userRef.getDocument { (document, error) in
				if let document = document, document.exists {
					let householdRef = document.get(FireStoreConstants.FieldHousehold) as! DocumentReference
					self.expensesRef = householdRef.collection(FireStoreConstants.CollectionPathExpenseTracker)
					
					self.expensesRef!.getDocuments() { (querySnapshot, err) in
						if let err = err {
							print("Error getting documents: \(err)")
						} else {
							if !querySnapshot!.documents.isEmpty {
								self.listener = self.expensesRef!.order(by: "last_modified", descending: false).addSnapshotListener { querySnapshot, error in
									guard let documents = querySnapshot?.documents else {
										print("Error fetching documents: \(error!)")
										return
									}
									self.expenses.removeAll()
									for document in documents {
										let name: String = document.get("name") as! String
										let price: Double = Double(document.get("price") as! String) ?? 0
										let description: String = document.get("description") as! String
										let date: Date = self.df.date(from: document.get("date") as! String)!
										self.expenses.append(ExpenseEntry(name: name, description: description, price: price, date: date, expenseId: document.documentID))
										print("\(document.documentID) => \(document.data())")
									}
									self.activityIndicatorView.stopAnimating()
									self.tableView.reloadData()
								}
							} else {
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
	
	deinit {
		listener!.remove()
	}
	
	//MARK: - UITableViewDataSource Protocol Methods
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return expenses.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "expenseTrackerCell", for: indexPath) as? ExpenseTrackerTableViewCell  else {
			fatalError("The dequeued cell is not an instance of ExpenseTrackerListTableViewCell.")
		}
		
		let expenseName = expenses[indexPath.row].name
		let expensePrice = expenses[indexPath.row].price
		
		cell.expenseName.text = expenseName
		cell.expensePrice.text = String(expensePrice)
		
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let selectedExpense = expenses[indexPath.row]
            
            expenses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            expensesRef!.document(selectedExpense.expenseId!).delete() { err in
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
	

	
    // MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		switch (segue.identifier ?? "") {
		case "showExpenseSegue":
			guard let showExpenseViewController = segue.destination as? ShowExpenseViewController else {
				fatalError("Unexpected destination: \(segue.destination)")
			}
			
			guard let selectedExpenseCell = sender as? ExpenseTrackerTableViewCell else {
				fatalError("Unexpected sender: \(sender ?? "Undeclared sender")")
			}
			
			guard let indexPath = tableView.indexPath(for: selectedExpenseCell) else {
				fatalError("The selected cell is not being displayed by the table")
			}
			
			let selectedExpense = expenses[indexPath.row]
			showExpenseViewController.expense = selectedExpense
			
		case "createExpenseSegue":
			os_log("Adding a new expense.", log: OSLog.default, type: .debug)
			
		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No segue defined")")
		}
	}

	//Used for Unwind Segues
	@IBAction func unwindToExpenseTracker(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? EditExpenseViewController, let expense = sourceViewController.expense {
			
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				
				// Update an existing meal.
				expenses[selectedIndexPath.row] = expense
				tableView.reloadRows(at: [selectedIndexPath], with: .none)
				
				expensesRef?.document(expense.expenseId!).updateData([
					"name": expense.name,
					"price": String(expense.price),
					"description": expense.description,
					"date": df.string(from: expense.date),
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
				let newIndexPath = IndexPath(row: expenses.count, section: 0)
				
				var ref: DocumentReference? = nil
				ref = expensesRef?.addDocument(data: [
					"name": expense.name,
					"price": String(expense.price),
					"description": expense.description,
					"date": df.string(from: expense.date),
					"last_modified": FieldValue.serverTimestamp()
				]) { err in
					if let err = err {
						print("Error adding document: \(err)")
					} else {
						print("Document added with ID: \(ref!.documentID)")
					}
				}
				expense.expenseId = ref!.documentID
				
				expenses.append(expense)
				tableView.insertRows(at: [newIndexPath], with: .automatic)
			}
		}
	}
}
