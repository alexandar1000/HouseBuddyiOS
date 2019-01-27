//
//  ExpenseEntry.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 17/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import Foundation

class ExpenseEntry {
	var name: String
	var description: String
	var price: Double
	
	init() {
		self.name = "Expense"
		self.description = ""
		self.price = 0.0
	}
	
	init(name: String, description: String, price: Double) {
		self.name = name
		self.description = description
		self.price = price
	}
}
