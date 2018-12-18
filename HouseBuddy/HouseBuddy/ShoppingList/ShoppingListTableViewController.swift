//
//  ShoppingListTableViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import os.log

class ShoppingListTableViewController: UITableViewController {
	
	var shoppingItems: Array<ShoppingItem> = [ShoppingItem(name: "Food"),
											  ShoppingItem(name: "Drinks"),
											  ShoppingItem(name: "Cake")]

	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
		//TODO: Split items into done and not done?
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return shoppingItems.count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "shoppingItemCell"
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShoppingListTableViewCell  else {
			fatalError("The dequeued cell is not an instance of ShoppingListTableViewCell.")
		}
		
		let name = shoppingItems[indexPath.row].name
		
		cell.nameLabel.text = name
		
		return cell
    }

	//MARK: Actions
	
	@IBAction func unwindToShoppingList(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? EditShoppingItemViewController, let shopItem = sourceViewController.shoppingItem {
			
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				// Update an existing meal.
				shoppingItems[selectedIndexPath.row] = shopItem
				tableView.reloadRows(at: [selectedIndexPath], with: .none)
			} else {
				// Add a new shoppingItem.
				let newIndexPath = IndexPath(row: shoppingItems.count, section: 0)
				shoppingItems.append(shopItem)
				tableView.insertRows(at: [newIndexPath], with: .automatic)
			}
		}
	}
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
			shoppingItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
	
	//MARK: Navigation Bar
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		switch (segue.identifier ?? "") {
		case "addNewShoppingItemSegue":
			os_log("Adding a new shopping item.", log: OSLog.default, type: .debug)
		case "editShoppingItemSegue":
			guard let editShoppingItemViewController = segue.destination as? EditShoppingItemViewController else {
				fatalError("Unexpected destination: \(segue.destination)")
			}
			
			guard let selectedShoppingItemCell = sender as? ShoppingListTableViewCell else {
				fatalError("Unexpected sender: \(sender ?? "Undeclared sender")")
			}
			
			guard let indexPath = tableView.indexPath(for: selectedShoppingItemCell) else {
				fatalError("The selected cell is not being displayed by the table")
			}
			
			let selectedMeal = shoppingItems[indexPath.row]
			editShoppingItemViewController.shoppingItem = selectedMeal
		
		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No segue defined")")
		}
	}

}
