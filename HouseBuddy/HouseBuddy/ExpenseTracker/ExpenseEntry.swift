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
	var date: Date
	var expenseId: String?
	
	init() {
		self.name = "Expense"
		self.description = ""
		self.price = 0.0
		self.date = Date()
		self.expenseId = ""
	}
	
	init(name: String, description: String, price: Double, date: Date) {
		self.name = name
		self.description = description
		self.price = price
		self.date = date
		self.expenseId = ""
	}
	
	init(name: String, description: String, price: Double, date: Date, expenseId: String) {
		self.name = name
		self.description = description
		self.price = price
		self.date = date
		self.expenseId = expenseId
	}

}
