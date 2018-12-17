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
	var price: Double
	var bought: Bool
	
	init() {
		self.name = "Expense"
		self.price = 0.0
		self.bought = false
	}
	
	init(name: String, price: Double, bought: Bool) {
		self.name = name
		self.price = price
		self.bought = bought
	}
}
