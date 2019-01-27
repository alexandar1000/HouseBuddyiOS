//
//  ExpenseTrackerTableViewCell.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 27/01/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class ExpenseTrackerTableViewCell: UITableViewCell {

	//MARK: - Outlets
	@IBOutlet weak var expenseName: UILabel!
	@IBOutlet weak var expensePrice: UILabel!
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
