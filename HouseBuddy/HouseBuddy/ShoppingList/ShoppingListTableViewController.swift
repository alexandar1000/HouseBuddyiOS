//
//  ShoppingListTableViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class ShoppingListTableViewController: UITableViewController {
	
	var shoppingItems: Array<ShoppingItem> = [ShoppingItem(name: "Food", price: 10.2, bought: true),
											  ShoppingItem(name: "Drinks", price: 3.5, bought: false),
											  ShoppingItem(name: "Cake", price: 7.9, bought: false)]

	
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
		let price = shoppingItems[indexPath.row].price
		
		cell.nameLabel.text = name
		cell.priceLabel.text = String(format:"%.2f", price)
		
		return cell
    }

	//MARK: Actions
	
	@IBAction func unwindToShoppingList(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? EditShoppingItemViewController, let shopItem = sourceViewController.shoppingItem {
			// Add a new shoppingItem.
			let newIndexPath = IndexPath(row: shoppingItems.count, section: 0)
			shoppingItems.append(shopItem)
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		}
	}
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
