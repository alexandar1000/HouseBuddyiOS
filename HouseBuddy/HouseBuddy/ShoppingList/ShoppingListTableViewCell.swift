//
//  ShoppingListTableViewCell.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 14/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

	// MARK: - Outlets
	@IBOutlet weak var nameLabel: UILabel!
	
	
	// MARK: - Cell Setup
	override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
