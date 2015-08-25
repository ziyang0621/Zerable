//
//  UserAddressCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class UserAddressCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
