//
//  HomeViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
	//MARK: Outlets
	
    @IBOutlet weak var householdNameLabel: UILabel!
    @IBOutlet weak var memberTableView: UITableView!
    
	// MARK: Fields
	
	let db = Firestore.firestore()
	var householdRef: DocumentReference?
	var memberListener: ListenerRegistration?
	
	var memberNames = [String]()
	
	let appDel = UIApplication.shared.delegate as! AppDelegate

	// MARK: Lifecycle methods
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		
		// Remove unneeded cell seperators
		memberTableView.tableFooterView = UIView()
		
		attachMemberListener()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Enable swipe to show drawer
		appDel.drawerController.screenEdgePanGestureEnabled = true
		
		let householdPath = UserDefaults.standard.string(forKey: StorageKeys.HouseholdPath)
		householdRef = db.document(householdPath!)
		
		let householdName = UserDefaults.standard.string(forKey: StorageKeys.HouseholdName) ?? ""
		if householdName.isEmpty {
			fetchHouseholdName()
		} else {
			householdNameLabel.text = householdName
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		memberListener?.remove()
	}
	
	// MARK: Private methods
	
	func fetchHouseholdName() {
		householdRef!.getDocument() { (document, err) in
			if let err = err {
				print("Failed to retrieve household name: \(err)")
			} else if document != nil && document!.exists {
				let householdName = document!.get(FireStoreConstants.FieldName) as! String
				
				UserDefaults.standard.set(householdName, forKey: StorageKeys.HouseholdName)
				self.householdNameLabel.text = householdName
			}
		}
	}
	
	func attachMemberListener() {
		memberListener = db.collection(FireStoreConstants.CollectionPathUsers).whereField(FireStoreConstants.FieldHousehold, isEqualTo: householdRef!).addSnapshotListener() { (querySnapshot, error) in
			guard let documents = querySnapshot?.documents else {
				print("Error fetching documents: \(error!)")
				return
			}
			
			self.memberNames.removeAll()
			for document in documents {
				let firstName = document.get(FireStoreConstants.FieldFirstName) as! String
				let lastName = document.get(FireStoreConstants.FieldLastName) as! String
				
				self.memberNames.append(firstName + " " + lastName)
			}
			
			self.memberTableView.reloadData()
		}
	}
	
	// MARK: UITableViewController
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return memberNames.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! UITableViewCell
		cell.textLabel?.text = memberNames[indexPath.item]
		cell.textLabel?.font = cell.textLabel?.font.withSize(15.0)
		return cell
	}
	
	// MARK: Actions
    
    @IBAction func toggleDrawer(_ sender: Any) {
		appDel.drawerController.setDrawerState(.opened, animated: true)
    }
}
