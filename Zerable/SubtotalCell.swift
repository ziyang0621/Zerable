//
//  SubtotalCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/11/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class SubtotalCell: UITableViewCell {
    
    @IBOutlet weak var subtotalLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
