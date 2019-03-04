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
	var userId: String
	
	init() {
		self.name = "Expense"
		self.description = ""
		self.price = 0.0
		self.date = Date()
		self.expenseId = ""
		self.userId = ""
	}
	
	init(name: String, description: String, price: Double, date: Date) {
		self.name = name
		self.description = description
		self.price = price
		self.date = date
		self.expenseId = ""
		self.userId = ""
	}
	
	init(name: String, description: String, price: Double, date: Date, expenseId: String) {
		self.name = name
		self.description = description
		self.price = price
		self.date = date
		self.expenseId = expenseId
		self.userId = ""
	}
	
	init(name: String, description: String, price: Double, date: Date, userId: String) {
		self.name = name
		self.description = description
		self.price = price
		self.date = date
		self.userId = userId
	}
	
	init(name: String, description: String, price: Double, date: Date, expenseId: String, userId: String) {
		self.name = name
		self.description = description
		self.price = price
		self.date = date
		self.expenseId = expenseId
		self.userId = userId
	}

}
