//
//  ShowExpenseViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 28/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class ShowExpenseViewController: UIViewController {

	//MARK: - Outlets
	@IBOutlet weak var dateLbl: UILabel!
	@IBOutlet weak var priceLbl: UILabel!
	@IBOutlet weak var nameLbl: UILabel!
	@IBOutlet weak var descriptionLbl: UILabel!
	
	//MARK: - Fields
    var expense: ExpenseEntry? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

        if let expense = expense {
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy"
            let createdAt = df.string(from: expense.date)
            dateLbl.text = createdAt
            priceLbl.text = String(expense.price)
            nameLbl.text = expense.name
            descriptionLbl.text = expense.description
        } else {
            dateLbl.text = ""
            priceLbl.text = ""
            nameLbl.text = ""
            descriptionLbl.text = ""
        }
    }
    
    //MARK: - Methods
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
 

}
