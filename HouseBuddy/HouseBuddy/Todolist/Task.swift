//
//  Task.swift
//  HouseBuddy
//
//  Created by R Riesebos on 02/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class Task: NSObject {
	
	var taskId: String? = nil
	var taskName: String
	var taskDesc: String?
	var isCompleted = false

	override init() {
		self.taskName = "Default Name"
	}

	init(taskId: String?, taskName: String, taskDesc: String?, isCompleted: Bool) {
		self.taskId = taskId
		self.taskName = taskName
		self.taskDesc = taskDesc
		self.isCompleted = isCompleted
	}
	
	init(taskName: String, taskDesc: String?) {
		self.taskName = taskName
		self.taskDesc = taskDesc
	}

	// Copy constructor
	init(original: Task) {
		self.taskId = original.taskId
		self.taskName = original.taskName
		self.taskDesc = original.taskDesc
		self.isCompleted = original.isCompleted
	}

	static func == (lhs: Task, rhs: Task) -> Bool {
		return lhs.taskId == rhs.taskId
			&& lhs.taskName == rhs.taskName
			&& lhs.taskDesc == rhs.taskDesc
			&& lhs.isCompleted == rhs.isCompleted
	}

}
