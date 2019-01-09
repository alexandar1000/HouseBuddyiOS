//
//  ShowTaskViewController.swift
//  HouseBuddy
//
//  Created by R Riesebos on 17/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ShowTaskViewController: UIViewController {
	
    @IBOutlet private weak var taskDescLabel: UILabel!
    
    var task = Task()

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Set title on navigation bar and set taskDescLabel to the task description
		title = task.taskName
		if task.taskDesc != nil, !task.taskDesc!.isEmpty {
        	taskDescLabel.text = task.taskDesc
		}
    }
	
	@IBAction func unwindFromAddTask(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? AddTaskViewController, let task = sourceViewController.task {
			
			// Change view controller state to represent the edited task
			title = task.taskName
			if task.taskDesc != nil, !task.taskDesc!.isEmpty {
				taskDescLabel.text = task.taskDesc
			}
			self.title = title
			
			// TODO: CHANGE TO HOUSEHOLD ID IN STORAGE ONCE IMPLEMENTED
			let firestore: Firestore = Firestore.firestore()
			if let user = Auth.auth().currentUser {
				let userId = user.uid
				let userRef = firestore.collection(FireStoreConstants.CollectionPathUsers).document(userId)
				
				userRef.getDocument { (document, error) in
					if let document = document, document.exists {
						let householdRef = document.get(FireStoreConstants.FieldHousehold) as! DocumentReference
						// Set query to the todo list collection reference
						let todoListRef = householdRef.collection(FireStoreConstants.CollectionPathToDoList)
						
						// Replace task in database with edited task
						if let id = task.taskId {
							todoListRef.document(id).setData([
								"taskName": task.taskName,
								"taskDesc": task.taskDesc ?? "",
								"completed": task.isCompleted
							]) { err in
								if let err = err {
									print("Error setting document data: \(err)")
								}
							}
						} else {
							print("Task doesn't have an id")
						}
					} else {
						print("Document does not exist")
					}
				}
			} else {
				print("No user signed in.")
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch(segue.identifier ?? "") {
		case "editTask":
			if let addTaskViewController = segue.destination as? AddTaskViewController {
				// Set the task in the add task view controller
				addTaskViewController.task = task
			}
			// Change back button text to "Cancel"
			let backItem = UIBarButtonItem()
			backItem.title = "Cancel"
			navigationItem.backBarButtonItem = backItem
			
			// Change title of destination to "Edit Task"
			let vc = segue.destination as UIViewController
			vc.navigationItem.title = "Edit Task"
		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier as String?)")
		}
	}

}
