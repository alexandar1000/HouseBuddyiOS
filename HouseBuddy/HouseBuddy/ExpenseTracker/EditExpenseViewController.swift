//
//  EditExpenseViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 28/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class EditExpenseViewController: UIViewController, UITextFieldDelegate {

	//MARK: - Outlets
    @IBOutlet weak var dateInput: UITextField!
    @IBOutlet weak var priceInput: UITextField!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextField!
    
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    //MARK: - Fields
    private var datePicker: UIDatePicker?
    private var df: DateFormatter = DateFormatter()
    
	//MARK: - Fields
	var expense: ExpenseEntry? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		priceInput.delegate = self
		titleInput.delegate = self
		descriptionInput.delegate = self
		
        df.dateFormat = "dd.MM.yyyy"
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        dateInput.inputView = datePicker
		
		let toolBarDate = UIToolbar().ToolbarPiker(mySelectNext: #selector(EditExpenseViewController.dismissPicker), mySelectDone: #selector(EditExpenseViewController.nextItemDateResponder))
		
		dateInput.inputAccessoryView = toolBarDate
		
		let toolBarPrice = UIToolbar().ToolbarPiker(mySelectNext: #selector(EditExpenseViewController.dismissPicker), mySelectDone: #selector(EditExpenseViewController.nextItemPriceResponder))
		
		priceInput.inputAccessoryView = toolBarPrice
		
		if (expense != nil) {
			dateInput.text = df.string(from: expense?.date ?? Date.init())
			priceInput.text = String(expense?.price ?? 0)
			titleInput.text = expense?.name ?? ""
			descriptionInput.text = expense?.description ?? ""
		} else {
			dateInput.text = df.string(from: Date.init())
		}
		
		updateSaveButtonState()
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        dateInput.text = df.string(from: sender.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let date = dateInput.text else {
            return
        }
        guard let price = priceInput.text else {
            return
        }
        guard let name = titleInput.text else {
            return
        }
        guard let description = descriptionInput.text else {
            return
        }
        
        let convertedDate: Date = df.date(from: date) ?? Date.init()
        let convertedPrice: Double = price.doubleValue
		
		if let entry = expense {
			expense = ExpenseEntry(name: name, description: description, price: convertedPrice, date: convertedDate, expenseId: entry.expenseId ?? "", userId: entry.userId)
		} else {
			let userId: String = UserDefaults.standard.string(forKey: StorageKeys.UserId) ?? ""
			expense = ExpenseEntry(name: name, description: description, price: convertedPrice, date: convertedDate, userId: userId)
		}
    }
	
	//MARK: Controlling the Keyboard
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == dateInput {
			textField.resignFirstResponder()
			priceInput.becomeFirstResponder()
		} else if textField == priceInput {
			textField.resignFirstResponder()
			titleInput.becomeFirstResponder()
		} else if textField == titleInput {
			textField.resignFirstResponder()
			descriptionInput.becomeFirstResponder()
		} else if textField == descriptionInput {
			textField.resignFirstResponder()
		}
		return true
	}
	
	private func updateSaveButtonState() {
		// Disable the Save button if the title and price field are empty.
		let name = titleInput.text ?? ""
		let price = priceInput.text ?? ""
		doneButton.isEnabled = !name.isEmpty && !price.isEmpty
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		updateSaveButtonState()
		
		switch textField {
		case dateInput:
			dateInput.text = textField.text
		case priceInput:
			priceInput.text = textField.text
		case descriptionInput:
			descriptionInput.text = textField.text
		case titleInput:
			titleInput.text = textField.text
		default:
			break
		}
	}
	
	@objc func dismissPicker() {
		
		view.endEditing(true)
		
	}
	
	@objc func nextItemDateResponder() {
		dateInput.resignFirstResponder()
		priceInput.becomeFirstResponder()
	}
	
	@objc func nextItemPriceResponder() {
		priceInput.resignFirstResponder()
		titleInput.becomeFirstResponder()
	}
}

extension String {
	static let numberFormatter = NumberFormatter()
	var doubleValue: Double {
		String.numberFormatter.decimalSeparator = "."
		if let result =  String.numberFormatter.number(from: self) {
			return result.doubleValue
		} else {
			String.numberFormatter.decimalSeparator = ","
			if let result = String.numberFormatter.number(from: self) {
				return result.doubleValue
			}
		}
		return 0
	}
}

extension UIToolbar {
	
	func ToolbarPiker(mySelectNext : Selector, mySelectDone : Selector) -> UIToolbar {
		
		let toolBar = UIToolbar()
		
		toolBar.barStyle = UIBarStyle.default
		toolBar.isTranslucent = true
		toolBar.tintColor = UIColor.black
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: mySelectNext)
		let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.plain, target: self, action: mySelectDone)
		
		let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
		
		toolBar.setItems([ nextButton, spaceButton, doneButton], animated: false)
		toolBar.isUserInteractionEnabled = true
		
		return toolBar
	}
	
}
