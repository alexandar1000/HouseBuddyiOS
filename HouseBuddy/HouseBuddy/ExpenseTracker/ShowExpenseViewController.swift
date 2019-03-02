//
//  ShowExpenseViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 28/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase

class ShowExpenseViewController: UIViewController {

	//MARK: - Outlets
	@IBOutlet weak var dateLbl: UILabel!
	@IBOutlet weak var priceLbl: UILabel!
	@IBOutlet weak var nameLbl: UILabel!
	@IBOutlet weak var descriptionLbl: UILabel!
	@IBOutlet weak var expensesUser: UILabel!
	
	//MARK: - Fields
    var expense: ExpenseEntry? = nil
	private var df: DateFormatter = DateFormatter()
	let db = Firestore.firestore()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        if let expense = expense {
            df.dateFormat = "dd.MM.yyyy"
            let createdAt = df.string(from: expense.date)
            dateLbl.text = createdAt
            priceLbl.text = String(expense.price)
            nameLbl.text = expense.name
            descriptionLbl.text = expense.description
			
			let docRef = db.collection("users").document(expense.userId)
			docRef.getDocument { (document, error) in
				if let document = document, document.exists {
					let firstName = document.get("first_name") as! String
					let lastName = document.get("last_name") as! String
					self.expensesUser.text = "\(firstName) \(lastName)"
				} else {
					print("Document does not exist")
				}
			}
		} else {
			self.dateLbl.text = ""
			self.priceLbl.text = ""
			self.nameLbl.text = ""
			self.descriptionLbl.text = ""
        }
    }
    
    //MARK: - Methods
    

    
    // MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		switch (segue.identifier ?? "") {
		case "editExpenseSegue":
			guard let editExpenseViewController = segue.destination as? EditExpenseViewController else {
				fatalError("Unexpected destination: \(segue.destination)")
			}
			
			guard let date = dateLbl.text else {
				return
			}
			guard let price = priceLbl.text else {
				return
			}
			guard let name = nameLbl.text else {
				return
			}
			guard let description = descriptionLbl.text else {
				return
			}
			
			
			let convertedDate: Date = df.date(from: date) ?? Date.init()
			let convertedPrice: Double = Double(price) ?? 0
			
			let entry = ExpenseEntry(name: name, description: description, price: convertedPrice, date: convertedDate, expenseId: expense?.expenseId ?? "", userId: expense?.userId ?? "")
			editExpenseViewController.expense = entry

		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "No segue defined")")
		}
	}
}
