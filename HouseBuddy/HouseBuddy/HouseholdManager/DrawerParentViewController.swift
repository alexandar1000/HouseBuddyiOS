//
//  DrawerParentViewController.swift
//  HouseBuddy
//
//  Created by Robert Riesebos on 28/02/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class DrawerParentViewController: UIViewController {
	// MARK: Fields
	
	var drawerVC: DrawerViewController!

	// MARK: Lifeycle methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	// MARK: Private methods
	
	func getDrawerViewController() -> DrawerViewController {
		return drawerVC
	}
	
	// MARK: Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? DrawerViewController, segue.identifier == "embedSegue" {
			self.drawerVC = vc
		}
	}

}
