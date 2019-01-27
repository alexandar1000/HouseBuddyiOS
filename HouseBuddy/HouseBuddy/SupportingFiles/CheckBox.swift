//
//  CheckBox.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 26/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

	// Images
	let checkedImage = UIImage(named: "ic_check_box")! as UIImage
	let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
	
	// Bool property
	var isChecked: Bool = false {
		didSet{
			if isChecked {
				self.setImage(checkedImage, for: UIControl.State.normal)
			} else {
				self.setImage(uncheckedImage, for: UIControl.State.normal)
			}
		}
	}
	
	override func awakeFromNib() {
		self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
		self.isChecked = false
	}
	
	@objc func buttonClicked(sender: UIButton) {
		if sender == self {
			isChecked = !isChecked
		}
	}

}
