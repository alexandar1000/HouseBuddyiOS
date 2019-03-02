//
//  ShowBalanceTableViewCell.swift
//  HouseBuddy
//
//  Created by Aleksandar Sasa on 02/03/2019.
//  Copyright © 2019 HouseBuddy. All rights reserved.
//

import UIKit

class ShowBalanceTableViewCell: UITableViewCell {
	@IBOutlet weak var nameLbl: UILabel!
	@IBOutlet weak var balanceLbl: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
