//
//  ExpenseTrackerViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 27/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class ExpenseTrackerViewController: UIViewController, UITableViewDataSource {

	// MARK: - Fields
	@IBOutlet weak var tableView: UITableView!
	var expenses: [ExpenseEntry] = [
	ExpenseEntry(name: "Food", description: "Party food", price: 7.99),
	ExpenseEntry(name: "Drinks", description: "Party Drinks", price: 4.58),
	ExpenseEntry(name: "Candles", description: "Cake Candles", price: 2.99)]
	
	
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "expenseTrackerCell")!
		
		let text = expenses[indexPath.row].name
		
		cell.textLabel?.text = text
		
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
