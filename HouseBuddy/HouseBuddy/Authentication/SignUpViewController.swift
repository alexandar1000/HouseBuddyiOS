//
//  SignuViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    //MARK: Fields
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfirmTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
				emailTF.delegate = self
				passwordTF.delegate = self
				passwordConfirmTF.delegate = self
				self.hideKeyboardWhenTappedAround()
    }
	
	//MARK: Firebase
    @IBAction func signUpAction(_ sender: Any) {
        if passwordTF.text != passwordConfirmTF.text {
            let alertController = UIAlertController(title: "Passwords do not match", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signUpToHome", sender: self)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
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
			passwordConfirmTF.becomeFirstResponder()
		} else if textField == passwordConfirmTF {
			passwordConfirmTF.resignFirstResponder()
		}
		return true
	}
}
