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
	@IBOutlet weak var expenseLbl: UILabel!
	private var usersBalance: Double = 0
	
	// MARK: - View Handling
    override func viewDidLoad() {
        super.viewDidLoad()
		
		df.dateFormat = "dd.MM.yyyy"
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
		// add border to the tableView
		tableView.layer.masksToBounds = true
		tableView.layer.borderColor = UIColor( red: 0/255, green: 0/255, blue:0/255, alpha: 1.0 ).cgColor
		tableView.layer.borderWidth = 0.7
		
		tableView.dataSource = self
        tableView.delegate = self
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		refreshBallance()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Hide the NavBar on appearing
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		self.navigationController?.setToolbarHidden(false, animated: animated)
		super.viewWillAppear(animated)
		
		if (expenses.isEmpty) {
			activityIndicatorView = UIActivityIndicatorView(style: .gray)
			tableView.backgroundView = activityIndicatorView
			activityIndicatorView.startAnimating()
			
		}
		
		refreshBallance()
		handleDBData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		// Show the NavBar on disappearing
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		self.navigationController?.setToolbarHidden(true, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	//Mark: Balance refreshing
	func refreshBallance() -> Void {
		let userId: String = UserDefaults.standard.string(forKey: StorageKeys.UserId) ?? ""
		
		let userRef = db.collection(FireStoreConstants.CollectionPathUsers).document(userId)
		
		userRef.getDocument { (document, error) in
			if let document = document, document.exists {
				self.usersBalance = document.get("balance") as! Double
				self.expenseLbl.text = "\(self.usersBalance)"
				
			} else {
				print("Document does not exist")
			}
		}
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
										let expenseUser: String = document.get("userId") as! String
										self.expenses.append(ExpenseEntry(name: name, description: description, price: price, date: date, expenseId: document.documentID, userId: expenseUser))
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
	
	deinit {
		if listener != nil {
			listener!.remove()
		}
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
			
			var nrOfMembers: Int = 0
			var balanceChange: Double = 0
			let userId: String = UserDefaults.standard.string(forKey: StorageKeys.UserId) ?? ""
			let householdPath: String = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath) ?? ""
			var owningUser: String = ""
			
			let membersRef = db.document(householdPath).collection(FireStoreConstants.CollectionPathMembers)
			membersRef.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error getting documents: \(err)")
				} else {
					nrOfMembers = querySnapshot!.documents.count
					balanceChange = selectedExpense.price / Double(nrOfMembers)
					var balance: Double = 0
					
					owningUser = selectedExpense.userId
						
					for document in querySnapshot!.documents {
						// Add to person who had the expense (you), subtract for all others
						let checkedUser: String = (document.get("user_reference") as! DocumentReference).documentID
						// Get the balance
						let userRef = self.db.collection(FireStoreConstants.CollectionPathUsers).document(checkedUser)
						userRef.getDocument { (document, error) in
							if let document = document, document.exists {
								balance = document.get("balance") as! Double
								if owningUser == checkedUser {
									userRef.updateData([
										"balance": balance - balanceChange
									]) { err in
										if let err = err {
											print("Error updating document: \(err)")
										} else {
											print("Document successfully updated")
										}
									}
									if userId == checkedUser {
										self.expenseLbl.text = "\(balance - balanceChange)"
									}
								} else {
									userRef.updateData([
										"balance": balance + balanceChange
									]) { err in
										if let err = err {
											print("Error updating document: \(err)")
										} else {
											print("Document successfully updated")
										}
									}
									if userId == checkedUser {
										self.expenseLbl.text = "\(balance + balanceChange)"
									}
								}
							} else {
								print("Document does not exist")
							}
						}
					}
				}
			}
            expensesRef!.document(selectedExpense.expenseId!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
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
			
		case "settleBalanceSegue":
			guard let settleBalanceTableViewController = segue.destination as? ShowBalanceTableViewController else {
				fatalError("Unexpected destination: \(segue.destination)")
			}
			settleBalanceTableViewController.isSettling = true
			settleBalanceTableViewController.navigationItem.title = "Settle Balance"
			
		case "showBalanceSegue":
			guard let showBalanceTableViewController = segue.destination as? ShowBalanceTableViewController else {
				fatalError("Unexpected destination: \(segue.destination)")
			}
			showBalanceTableViewController.navigationItem.title = "Current Balance"
			
		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No segue defined")")
		}
	}

	//Used for Unwind Segues
	@IBAction func unwindToExpenseTracker(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? EditExpenseViewController, let expense = sourceViewController.expense {
			
			var nrOfMembers: Int = 0
			var balanceChange: Double = 0
			let userId: String = UserDefaults.standard.string(forKey: StorageKeys.UserId) ?? ""
			let householdPath: String = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath) ?? ""
			
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				
				let oldPrice = expenses[selectedIndexPath.row].price
				
				// Update an existin meal.
				expenses[selectedIndexPath.row] = expense
				tableView.reloadRows(at: [selectedIndexPath], with: .none)
				
				expensesRef?.document(expense.expenseId!).updateData([
					"name": expense.name,
					"price": String(expense.price),
					"description": expense.description,
					"date": df.string(from: expense.date),
					"userId": UserDefaults.standard.string(forKey: StorageKeys.UserId) ?? "",
					"last_modified": FieldValue.serverTimestamp()
				]) { err in
					if let err = err {
						print("Error updating document: \(err)")
					} else {
						print("Document successfully updated")
					}
				}
				
				if (oldPrice != expense.price) {
					// Regulate the costs between users
					var owningUser: String = ""
					owningUser = expense.userId
					
					let membersRef = db.document(householdPath).collection(FireStoreConstants.CollectionPathMembers)
					membersRef.getDocuments() { (querySnapshot, err) in
						if let err = err {
							print("Error getting documents: \(err)")
						} else {
							nrOfMembers = querySnapshot!.documents.count
							balanceChange = (expense.price - oldPrice) / Double(nrOfMembers)
							var balance: Double = 0
							
							for document in querySnapshot!.documents {
								// Add to person who had the expense (you), subtract for all others
								let checkedUser: String = document.documentID
								// Get the balance
								let userRef = self.db.collection(FireStoreConstants.CollectionPathUsers).document(checkedUser)
								userRef.getDocument { (document, error) in
									if let document = document, document.exists {
										balance = document.get("balance") as! Double
										if owningUser == checkedUser {
											userRef.updateData([
												"balance": balance + balanceChange
											]) { err in
												if let err = err {
													print("Error updating document: \(err)")
												} else {
													print("Document successfully updated")
												}
											}
											if userId == checkedUser {
												self.expenseLbl.text = "\(balance + balanceChange)"
											}
										} else {
											userRef.updateData([
												"balance": balance - balanceChange
											]) { err in
												if let err = err {
													print("Error updating document: \(err)")
												} else {
													print("Document successfully updated")
												}
											}
											if userId == checkedUser {
												self.expenseLbl.text = "\(balance - balanceChange)"
											}
										}
									} else {
										print("Document does not exist")
									}
								}
							}
						}
					}
				}
			} else {
				
				// Add a new expense.
				let newIndexPath = IndexPath(row: expenses.count, section: 0)
				
				var ref: DocumentReference? = nil
				ref = expensesRef?.addDocument(data: [
					"name": expense.name,
					"price": String(expense.price),
					"description": expense.description,
					"date": df.string(from: expense.date),
					"userId": UserDefaults.standard.string(forKey: StorageKeys.UserId) ?? "",
					"last_modified": FieldValue.serverTimestamp()
				]) { err in
					if let err = err {
						print("Error adding document: \(err)")
					} else {
						print("Document added with ID: \(ref!.documentID)")
					}
				}
				
				// Regulate the costs between users
				let membersRef = db.document(householdPath).collection(FireStoreConstants.CollectionPathMembers)
				membersRef.getDocuments() { (querySnapshot, err) in
					if let err = err {
						print("Error getting documents: \(err)")
					} else {
						nrOfMembers = querySnapshot!.documents.count
						balanceChange = expense.price / Double(nrOfMembers)
						var balance: Double = 0
						
						for document in querySnapshot!.documents {
							// Add to person who had the expense (you), subtract for all others
							let userRef: String = (document.get("user_reference") as! DocumentReference).path
							
							// Get the balance
							self.db.document(userRef).getDocument { (document, error) in
								if let document = document, document.exists {
									balance = document.get("balance") as! Double
									
									if  userRef == "users/\(userId)" {
										self.db.document(userRef).updateData([
											"balance": balance + balanceChange
										]) { err in
											if let err = err {
												print("Error updating document: \(err)")
											} else {
												print("Document successfully updated")
											}
										}
										self.expenseLbl.text = "\(balance + balanceChange)"
									} else {
										self.db.document(userRef).updateData([
											"balance": balance - balanceChange
										]) { err in
											if let err = err {
												print("Error updating document: \(err)")
											} else {
												print("Document successfully updated")
											}
										}
									}
								} else {
									print("Document does not exist")
								}
							}
						}
					}
				}
				
				expense.expenseId = ref!.documentID
				
				expenses.append(expense)
				tableView.insertRows(at: [newIndexPath], with: .automatic)
			}
		}
	}
	
	
    // MARK: Actions
    
    @IBAction func menuAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.drawerController.setDrawerState(.opened, animated: true)
    }
    
}
