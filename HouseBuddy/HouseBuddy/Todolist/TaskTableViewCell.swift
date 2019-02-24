//
//  TaskTableViewCell.swift
//  HouseBuddy
//
//  Created by R Riesebos on 02/12/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: Properties
	
    @IBOutlet weak var taskNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
