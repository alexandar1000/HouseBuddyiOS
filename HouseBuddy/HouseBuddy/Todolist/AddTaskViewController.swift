//
//  AddTaskViewController.swift
//  HouseBuddy
//
//  Created by R Riesebos on 17/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Outlets
	
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var descTextField: UITextField!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
	
	// MARK: Fields
	
    var task: Task?

	// MARK: Lifecycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Task is passed by previous view, set text in text fields to task properties
		if task != nil {
			nameTextField.text = task?.taskName
			descTextField.text = task?.taskDesc
		}
		
		// Handle the text field’s user input through delegate callbacks
        nameTextField.delegate = self
        descTextField.delegate = self
		
		// Enable the Save button only if the text field has a valid Task name
		updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Select all text in the textfield
		textField.becomeFirstResponder()
		textField.selectAll(nil)
		
		// Disable the Save button while editing.
		saveButton.isEnabled = false
	}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
		updateSaveButtonState()
		
        switch textField {
            case nameTextField:
                nameTextField.text = textField.text
            case descTextField:
                descTextField.text = textField.text
            default:
                break
        }
    }
	
	// MARK: Private methods
	
	private func updateSaveButtonState() {
		// Disable the Save button if the name field is empty.
		let text = nameTextField.text ?? ""
		saveButton.isEnabled = !text.isEmpty
	}
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = nameTextField.text ?? ""
		let desc = descTextField.text
        
        // Set the task to be passed to TaskTableViewController after the unwind segue.
		task = Task(taskId: task?.taskId, taskName: name, taskDesc: desc, isCompleted: task?.isCompleted ?? false)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
    }
    
}
