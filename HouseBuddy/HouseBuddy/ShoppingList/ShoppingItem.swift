//
//  ShoppingItem.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import Foundation

class ShoppingItem {
	var name: String
	var itemID: String?
	var bought: Bool
	var description: String?
	
	
	init() {
		self.name = "Shopping Item"
		self.bought = false
		self.itemID = nil
		self.description = ""
	}
	
	init(name: String) {
		self.name = name
		self.bought = false
		self.itemID = nil
		self.description = ""
	}
	
	init(name: String, bought: Bool, itemID: String) {
		self.name = name
		self.bought = bought
		self.itemID = itemID
		self.description = ""
	}
	
	init(name: String, description: String, bought: Bool, itemID: String) {
		self.name = name
		self.bought = bought
		self.itemID = itemID
		self.description = description
	}
	
}
