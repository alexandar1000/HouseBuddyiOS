//
//  EditShoppingItemViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import BEMCheckBox

class EditShoppingItemViewController: UIViewController, UITextFieldDelegate, BEMCheckBoxDelegate {

	// MARK - Outlets
	@IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
	@IBOutlet weak var boughtCheckBox: BEMCheckBox!
	
	// MARK: - Field Setup
	var shoppingItem: ShoppingItem? = nil
	var completeness: Bool = false
	
	// MARK: - View Handling
	override func viewDidLoad() {
        super.viewDidLoad()

		self.itemName.delegate = self
		self.boughtCheckBox.delegate = self
		// Set up the ShoppingItem if editing an existing ShoppingItem
		if let shoppingItem = shoppingItem {
			navigationItem.title = "Edit Shopping Item"
			itemName.text = shoppingItem.name
			completeness = shoppingItem.bought
			self.boughtCheckBox.on = completeness
		}
		
		updateSaveButtonState()
    }
	
	//MARK: - Actions
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
	
	//MARK: BEMCheckBoxDelegate Actions
	func didTap(_ checkBox: BEMCheckBox) {
		self.completeness = boughtCheckBox.on
	}
	
	
	private func updateSaveButtonState() {
		// Disable the Save button if the name field is empty.
		let text = itemName.text ?? ""
		doneButton.isEnabled = !text.isEmpty
	}
	
    // MARK: - Navigation
	
	// Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
		
		//Make sure the textField exists (although implied)
		guard let name = itemName.text else {
			return
		}
		
		//Update the item with the newest data (just before updating the list)
		if let item = shoppingItem {
			shoppingItem = ShoppingItem(name: name, bought: completeness, itemID: item.itemID!)
		} else {
			shoppingItem = ShoppingItem(name: name)
		}
    }
	
	// MARK: - Input Handling
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
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		updateSaveButtonState()
		
		switch textField {
		case itemName:
			itemName.text = itemName.text
		default:
			break
		}
	}
}
