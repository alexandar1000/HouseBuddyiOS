//
//  ExpenseTrackerViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 27/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import os.log

class ExpenseTrackerViewController: UIViewController, UITableViewDataSource {

	// MARK: - Fields
	@IBOutlet weak var tableView: UITableView!
	var expenses: [ExpenseEntry] = [
		ExpenseEntry(name: "Food", description: "Party food", price: 7.99, date: Date()),
		ExpenseEntry(name: "Drinks", description: "Party Drinks", price: 4.58, date: Date()),
		ExpenseEntry(name: "Candles", description: "Cake Candles", price: 2.99, date: Date())]
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//add border to the tableView
		tableView.layer.masksToBounds = true
		tableView.layer.borderColor = UIColor( red: 0/255, green: 0/255, blue:0/255, alpha: 1.0 ).cgColor
		tableView.layer.borderWidth = 0.7
		
		tableView.dataSource = self

        // Do any additional setup after loading the view.
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
			
		case "editExpenseSegue":
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
				
			} else {
				
				// Add a new shoppingItem.
				let newIndexPath = IndexPath(row: expenses.count, section: 0)
				
				expenses.append(expense)
				tableView.insertRows(at: [newIndexPath], with: .automatic)
			}
		}
	}
}
