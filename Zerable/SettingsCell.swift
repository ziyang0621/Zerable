//
//  SettingsCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/8/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet private weak var settingsLabel: UILabel!
    
    var indexPath: NSIndexPath? {
        didSet {
            if let indexPath = indexPath {
                if indexPath.section == 3 {
                    settingsLabel.text = "Log Out"
                    settingsLabel.textColor = UIColor.redColor()
                }
                else {
                    settingsLabel.textColor = UIColor.blackColor()
                    if indexPath.section == 0 {
                        settingsLabel.text = "Profile"
                    }
                    else if indexPath.section == 1 {
                        if indexPath.row == 0 {
                            settingsLabel.text = "About"
                        } else if indexPath.row == 1 {
                            settingsLabel.text = "Tell a Friend"
                        } else {
                            settingsLabel.text = "Rate Our App"
                        }
                    }
                    else if indexPath.section == 2 {
                        settingsLabel.text = "Contact Us"
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
