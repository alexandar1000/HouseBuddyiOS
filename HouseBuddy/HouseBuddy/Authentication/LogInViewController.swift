//
//  LoginViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
	//MARK: Fields
	@IBOutlet weak var emailTF: UITextField!
	@IBOutlet weak var passwordTF: UITextField!
	@IBOutlet weak var logInBtn: UIButton!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		emailTF.delegate = self
		passwordTF.delegate = self
		self.hideKeyboardWhenTappedAround()
	}
	
	//MARK: Firebase
	@IBAction func logInAction(_ sender: Any) {
		Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { (user, error) in
			if error == nil{
				self.performSegue(withIdentifier: "logInToHome", sender: self)
			} else {
				let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
				let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
					
				alertController.addAction(defaultAction)
				self.present(alertController, animated: true, completion: nil)
			}
		}
	}
	
	//MARK: Controlling the Keyboard
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailTF {
			textField.resignFirstResponder()
			passwordTF.becomeFirstResponder()
		} else if textField == passwordTF {
			textField.resignFirstResponder()
		}
		return true
	}
	
}
