//
//  AddTaskViewController.swift
//  HouseBuddy
//
//  Created by R Riesebos on 17/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITextFieldDelegate {
	
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Handle the text field’s user input through delegate callbacks
        nameTextField.delegate = self
        descTextField.delegate = self
		
		// Enable the Save button only if the text field has a valid Task name
		updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
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
        task = Task(taskName: name, taskDesc: desc)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
		// AddTaskViewController is shown modally, so we use dismiss instead of
        // navigationController?.popViewController(animated: true)
		dismiss(animated: true, completion: nil)
    }
    
}
