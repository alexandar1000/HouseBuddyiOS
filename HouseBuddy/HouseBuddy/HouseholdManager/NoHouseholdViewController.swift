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
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if self.isMovingFromParent {
			// Back button is pressed, sign out
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
	
	// MARK: Actions
    
    @IBAction func joinHousehold(_ sender: Any) {
		// TODO: implement joining (with invite code)
    }
    
    @IBAction func createHousehold(_ sender: Any) {
		// TODO: implement creating a household
    }

}
