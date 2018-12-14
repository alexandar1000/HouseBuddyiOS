//
//  TaskTableViewController.swift
//  HouseBuddy
//
//  Created by R Riesebos on 02/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TaskTableViewController: UITableViewController {

	//MARK: Properties

	private var taskList: [Task] = []
	
	fileprivate var query: Query? {
		didSet {
			if let listener = listener {
				listener.remove()
				observeQuery()
			}
		}
	}
	
	private var listener: ListenerRegistration?
	
	fileprivate func stopObserving() {
		listener?.remove()
	}
	
	fileprivate func observeQuery() {
		guard let query = query else { return }
		stopObserving()
		
		listener = query.addSnapshotListener { (querySnapshot, error) in
			guard let documents = querySnapshot?.documents else {
				print("Error fetching documents: \(error!)")
				return
			}
			
			self.taskList.removeAll()
			for document in documents {
				self.taskList.append(Task(taskId: document.documentID, taskName: document.get("taskName") as! String,
										  taskDesc: document.get("taskDesc") as! String, isCompleted: document.get("completed") as! Bool))
			}
			self.tableView.reloadData()
		}
	}
	
	fileprivate func baseQuery() {
		let firestore: Firestore = Firestore.firestore()
		
		// TODO: This part should be moved to future HouseHoldManager class
		let settings = firestore.settings
		settings.areTimestampsInSnapshotsEnabled = true
		firestore.settings = settings
		
		// TODO: Retrieving household id should be moved to HouseHoldManager class where it's put in the device storage..
		if let user = Auth.auth().currentUser {
			let userId = user.uid
			let userRef = firestore.collection(FireStoreConstants.CollectionPathUsers).document(userId)
			
			userRef.getDocument { (document, error) in
				if let document = document, document.exists {
					let householdRef = document.get(FireStoreConstants.FieldHousehold) as! DocumentReference
					// Set query to the todo list collection reference
					self.query = householdRef.collection(FireStoreConstants.CollectionPathToDoList)
					
					self.observeQuery()
				} else {
					print("Document does not exist")
				}
			}
		} else {
			print("No user signed in.")
		}
	}

    override func viewDidLoad() {
		super.viewDidLoad()
		baseQuery()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		stopObserving()
	}
	
	deinit {
		listener?.remove()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Table view cells are reused and should be dequeued using a cell identifier.
		let cellIdentifier = "TaskTableViewCell"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell else {
				fatalError("The dequeued cell is not an instance of TaskTableViewCell.")
		}

		// Fetches the appropriate task for the data source layout.
		let task = taskList[indexPath.row]
		cell.taskNameLabel.text = task.taskName

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
