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
import os.log

class TaskTableViewController: UITableViewController {

    //MARK: Properties

	private var taskList = [Task]()
	var clickedTask = Task()
	
	// Reference to the to_do_list collection
	fileprivate var query: Query? {
		didSet {
			// Query is set, we are ready to attach a listener to it
			observeQuery()
		}
	}
	
	var activityIndicatorView: UIActivityIndicatorView!
	let dispatchQueue = DispatchQueue(label: "Retrieving Tasks from FireStore")
	
	private var listener: ListenerRegistration?
	
	// MARK: Private methods
	
	fileprivate func stopObserving() {
		listener?.remove()
	}
	
	fileprivate func observeQuery() {
		// Make sure that query is actually set (not nil)
		guard let query = query else { return }
		
		// Detach listener before attaching a new one
		stopObserving()
		
		listener = query.addSnapshotListener { (querySnapshot, error) in
			guard let documents = querySnapshot?.documents else {
				print("Error fetching documents: \(error!)")
				return
			}
			
			// Clear taskList and set it to it's new state
			self.taskList.removeAll()
			for document in documents {
				self.taskList.append(Task(taskId: document.documentID, taskName: document.get("taskName") as! String,
										  taskDesc: document.get("taskDesc") as? String, isCompleted: document.get("completed") as! Bool))
			}
			
			// taskList is initialized, stop loading animation and reload the table's data
			self.activityIndicatorView.stopAnimating()
			self.tableView.separatorStyle = .singleLine
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
				} else {
					print("Document does not exist")
				}
			}
		} else {
			print("No user signed in.")
		}
	}
	
	fileprivate func addTask(task: Task) {
		// Add a new document with a generated id.
		var ref: DocumentReference? = nil
		if let todoListRef = query as? CollectionReference {
			ref = todoListRef.addDocument(data: [
				"taskName": task.taskName,
				"taskDesc": task.taskDesc ?? "",
				"completed": task.isCompleted
			]) { err in
				if let err = err {
					os_log("Error adding document", log: OSLog.default, type: .debug)
					print(err);
				} else {
					// Set auto generated FireStore id as task id
					task.taskId = ref!.documentID
				}
			}
		}
	}
	
	// MARK: LifeCycle methods
	
	override func loadView() {
		super.loadView()
		
		// Initialize the table's background view to the loading indicator
		activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		tableView.backgroundView = activityIndicatorView
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Start loading animation and call baseQuery on a seperate thread
		if (taskList.isEmpty) {
			activityIndicatorView.startAnimating()
			tableView.separatorStyle = .none
			
			dispatchQueue.async {
				self.baseQuery()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	deinit {
		// Detach listener when it's no longer needed
		stopObserving()
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		clickedTask = taskList[indexPath.row]
		
		// Segue to the show task view controller
		performSegue(withIdentifier: "showTask", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == UITableViewCell.EditingStyle.delete {
			// Delete task by deleteing document with the task id
			clickedTask = taskList[indexPath.row]
			if let todoListRef = query as? CollectionReference {
				if let documentId = clickedTask.taskId {
					todoListRef.document(documentId).delete() { err in
						if let err = err {
							os_log("Error deleting document", log: OSLog.default, type: .debug)
							print(err)
						}
					}
				}
			}
		}
	}
	
	// MARK: Actions
	
	@IBAction func unwindFromAddTask(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.source as? AddTaskViewController, let task = sourceViewController.task {
			// Add a new task
			addTask(task: task)
			/*let newIndexPath = IndexPath(row: taskList.count, section: 0)
			taskList.append(task)
			tableView.insertRows(at: [newIndexPath], with: .automatic)*/
		}
	}
	
	// MARK: Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch(segue.identifier ?? "") {
		case "showTask":
			if let showTaskViewController = segue.destination as? ShowTaskViewController {
				// Set the task in the show task view controller
				showTaskViewController.task = clickedTask
			}
		case "addTask":
			// Change back button text to "Cancel"
			let backItem = UIBarButtonItem()
			backItem.title = "Cancel"
			navigationItem.backBarButtonItem = backItem
		default:
			fatalError("Unexpected Segue Identifier; \(segue.identifier as String?)")
		}
	}

}
