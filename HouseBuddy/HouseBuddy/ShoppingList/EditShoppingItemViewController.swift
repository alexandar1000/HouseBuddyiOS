//
//  EditShoppingItemViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class EditShoppingItemViewController: UIViewController {

	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	var shoppingItem:ShoppingItem? = nil
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
		
		// Configure the destination view controller only when the save button is pressed.
		guard let button = sender as? UIBarButtonItem, button === doneButton else {
			print("The save button was not pressed, cancelling")
			return
		}
		//UPDATE THIS TO ACTUALLY RETURN PROPER DATA
		shoppingItem = ShoppingItem(name: "Test Item", price: 7.01, bought: true)
    }

}
