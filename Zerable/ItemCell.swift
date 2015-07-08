//
//  ItemCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/30/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    
    var itemImage: UIImage? {
        didSet {
            if let itemImage = itemImage {
                itemImageView.image = itemImage
            }
        }
    }
    
    var itemName: String? {
        didSet {
            if let itemName = itemName {
                itemNameLabel.text = itemName
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemImageView.clipsToBounds = true
        itemNameLabel.shadowColor = UIColor.blackColor()
        itemNameLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
