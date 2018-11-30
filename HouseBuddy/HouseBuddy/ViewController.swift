//
//  ViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 22/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

  override func viewDidLoad() {
    super.viewDidLoad()
	}

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}


// Closes the keyboard when pressed anywhere. If deleting the class, move the following code to another class
extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
