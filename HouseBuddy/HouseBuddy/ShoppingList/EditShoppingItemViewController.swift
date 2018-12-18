//
//  EditShoppingItemViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class EditShoppingItemViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
	
	var shoppingItem:ShoppingItem? = nil
	
	override func viewDidLoad() {
        super.viewDidLoad()

		self.itemName.delegate = self
        // Do any additional setup after loading the view
		
		// Set up the ShoppingItem if editing an existing ShoppingItem
		if let shoppingItem = shoppingItem {
			navigationItem.title = "Edit Shopping Item"
			itemName.text = shoppingItem.name
		}
    }
    
	@IBAction func doneButtonTapped(_ sender: Any) {
		if let name = itemName.text, !name.isEmpty {
			performSegue(withIdentifier: "unwindToShoppingListSegue", sender: self)
		} else {
			showErrorEmptyField()
		}
	}
	
	@IBAction func cancelEdditingItem(_ sender: Any) {
		if let navigationController = navigationController {
			navigationController.popViewController(animated: true)
		} else {
			fatalError("The EditShoppingItemViewController is not inside a navigation controller.")
		}
	}
	
	
    // MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
		
		//Make sure the textField exists (although implied)
		guard let name = itemName.text else {
			return
		}
		
		//Update the item with he newest data (just before updating the list)
		shoppingItem = ShoppingItem(name: name)
    }
	
	
	func showErrorEmptyField() {
		let alert = UIAlertController(title: "Error", message: "Please Enter Item Name", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		
		present(alert, animated: true)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
