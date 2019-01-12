//
//  ShowTaskViewController.swift
//  HouseBuddy
//
//  Created by WJ Riesebos on 17/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class ShowTaskViewController: UIViewController {
	
    @IBOutlet weak var taskDescLabel: UILabel!
    
    var task = Task()

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Set title on navigation bar and set taskDescLabel to the task description
		title = task.taskName
		if task.taskDesc != nil, !task.taskDesc!.isEmpty {
        	taskDescLabel.text = task.taskDesc
		}
    }

}
