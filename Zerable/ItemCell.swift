//
//  ItemCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/30/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemImageView.clipsToBounds = true
        itemNameLabel.shadowColor = UIColor.blackColor()
        itemNameLabel.shadowOffset = CGSize(width: 0.5, height: 0.5)
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
