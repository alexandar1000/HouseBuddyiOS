//
//  EditExpenseViewController.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 28/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class EditExpenseViewController: UIViewController {

	//MARK: - Outlets
    @IBOutlet weak var dateInput: UITextField!
    @IBOutlet weak var priceInput: UITextField!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextField!
    
    
    //MARK: - Fields
    private var datePicker: UIDatePicker?
    private var df: DateFormatter = DateFormatter()
    
	//MARK: - Fields
	var expense: ExpenseEntry? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "dd.MM.yyyy"
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        dateInput.inputView = datePicker
		
		if (expense != nil) {
			dateInput.text = df.string(from: expense?.date ?? Date.init())
			priceInput.text = String(expense?.price ?? 0)
			titleInput.text = expense?.name ?? ""
			descriptionInput.text = expense?.description ?? ""
		}
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
			expense = ExpenseEntry(name: name, description: description, price: convertedPrice, date: convertedDate, expenseId: entry.expenseId ?? "")
		} else {
			expense = ExpenseEntry(name: name, description: description, price: convertedPrice, date: convertedDate)
		}
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
