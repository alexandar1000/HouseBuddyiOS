//
//  ShowShoppingItemViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 25/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class ShowShoppingItemViewController: UIViewController {
	
	// MARK: - Fields
	var shoppingItem: ShoppingItem? = nil
	
	//MARK: - Outlets
	@IBOutlet weak var nameLbl: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set up the ShoppingItem if presenting an existing ShoppingItem
		if let shoppingItem = shoppingItem {
			//populate the
			nameLbl.text = shoppingItem.name
		} else {
			nameLbl.text = ""
		}
    }
	
    // MARK: - Navigation
	
    //Prepare for the segue to take place
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		switch (segue.identifier ?? "") {

			case "editShownShoppingItemSegue":
				guard let editShoppingItemViewController = segue.destination as? EditShoppingItemViewController else {
					fatalError("Unexpected destination: \(segue.destination)")
				}

				editShoppingItemViewController.shoppingItem = shoppingItem
			
			default:
				fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No segue defined")")
		}
	}
}
