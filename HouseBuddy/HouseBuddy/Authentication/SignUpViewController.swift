//
//  SignuViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

  //MARK: Fields
  @IBOutlet weak var nameTF: UITextField!
  @IBOutlet weak var surnameTF: UITextField!
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!
  @IBOutlet weak var passwordConfirmTF: UITextField!
  @IBOutlet weak var signUpBtn: UIButton!
	
  override func viewDidLoad() {
		super.viewDidLoad()
		nameTF.delegate = self
		surnameTF.delegate = self
		emailTF.delegate = self
		passwordTF.delegate = self
		passwordConfirmTF.delegate = self
		self.hideKeyboardWhenTappedAround()
	}
	
	//MARK: - Navigation
  @IBAction func signUpAction(_ sender: Any) {
		if passwordTF.text != passwordConfirmTF.text {
      let alertController = UIAlertController(title: "Passwords do not match", message: "Please re-type password", preferredStyle: .alert)
      let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
      alertController.addAction(defaultAction)
      self.present(alertController, animated: true, completion: nil)
        } else if (self.nameTF.text?.isEmpty)! ||
            (self.surnameTF.text?.isEmpty)! || (self.emailTF.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Not all information entered", message: "Please enter all of the information", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
		  Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { (user, error) in
          if error == nil {
        	self.performSegue(withIdentifier: "signUpToHome", sender: self)
		  } else {
        	let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        	let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
        	alertController.addAction(defaultAction)
        	self.present(alertController, animated: true, completion: nil)
		  }
    	}
	  }
	}
	
	// Prepares for the segue to take place
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		if segue.identifier == "signUpToHome" {
			let destVC = segue.destination as! HomeViewController
			destVC.userName = nameTF.text!
			destVC.userSurname = surnameTF.text!
			destVC.userEmail = emailTF.text!
		}
	}
	
	//MARK: Controlling the Keyboard
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            textField.resignFirstResponder()
            surnameTF.becomeFirstResponder()
        } else if textField == surnameTF {
            textField.resignFirstResponder()
            emailTF.becomeFirstResponder()
        } else if textField == emailTF {
			textField.resignFirstResponder()
			passwordTF.becomeFirstResponder()
		} else if textField == passwordTF {
			textField.resignFirstResponder()
			passwordConfirmTF.becomeFirstResponder()
		} else if textField == passwordConfirmTF {
			passwordConfirmTF.resignFirstResponder()
		}
		return true
	}
}

