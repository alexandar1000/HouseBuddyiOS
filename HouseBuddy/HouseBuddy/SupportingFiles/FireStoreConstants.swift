//
//  FireStoreConstants.swift
//  HouseBuddy
//
//  Created by R Riesebos on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import Foundation

struct FireStoreConstants {
	static let CollectionPathUsers = "users"
	static let CollectionPathToDoList = "to_do_list"
	static let CollectionPathShoppingList = "shopping_list"
	static let CollectionPathExpenseTracker = "expense_tracker"
	static let CollectionPathInvites = "invites"
	static let CollectionPathMembers = "members"
	static let CollectionPathHouseholds = "households"
	
	// TODO: add change log
	static let HouseholdCollectionPaths = [ CollectionPathToDoList, CollectionPathShoppingList, CollectionPathExpenseTracker, "expenses_list" ]
	
	static let FieldHousehold = "household"
	static let FieldColor = "color"
	static let FieldUserReference = "user_reference"
	static let FieldInviteCode = "invite_code"
	static let FieldName = "name"
	static let FieldFirstName = "first_name"
	static let FieldLastName = "last_name"
	static let FieldCurrentUserBalance = "balance"
}
