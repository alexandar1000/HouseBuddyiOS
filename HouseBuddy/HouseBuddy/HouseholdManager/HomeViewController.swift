//
//  HomeViewController.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 30/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
	//MARK: Outlets
	
    @IBOutlet weak var householdNameLabel: UILabel!
	
	// MARK: Fields
	
	let appDel = UIApplication.shared.delegate as! AppDelegate

	// MARK: Lifecycle methods
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Enable swipe to show drawer
		appDel.drawerController.screenEdgePanGestureEnabled = true
	}
	
	// MARK: Actions
    
    @IBAction func toggleDrawer(_ sender: Any) {
		appDel.drawerController.setDrawerState(.opened, animated: true)
    }
}
