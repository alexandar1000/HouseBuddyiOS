//
//  NoHouseholdViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 08/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class NoHouseholdViewController: UIViewController {
	
    // MARK: Lifecycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
    
    @IBAction func signOut(_ sender: Any) {
		do {
		try Auth.auth().signOut()
		GIDSignIn.sharedInstance().signOut()
	
		// Remove stored household path
		UserDefaults.standard.set("", forKey: StorageKeys.HOUSEHOLD_PATH)
		} catch let signOutError as NSError {
		print ("Error signing out: %@", signOutError)
		}
	
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let initial = storyboard.instantiateInitialViewController()
		UIApplication.shared.keyWindow?.rootViewController = initial
    }
}
