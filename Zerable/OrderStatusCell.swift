//
//  OrderStatusCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/26/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class OrderStatusCell: UITableViewCell {
    
    @IBOutlet weak var orderStatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
