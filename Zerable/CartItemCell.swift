//
//  CartItemCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class CartItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    var miniQuantity = 0
    var maxQuantity = 0
    var currentQuantity: Int? {
        didSet {
            if let currentQuantity = currentQuantity {
                quantityLabel.text = "\(currentQuantity)"
            }
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImageView.clipsToBounds = true
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func minusButtonTapped(sender: AnyObject) {
        if currentQuantity > miniQuantity {
            currentQuantity!--
        }
    }
    
    @IBAction func plusButtonTapped(sender: AnyObject) {
        if currentQuantity < maxQuantity {
            currentQuantity!++
        }
    }
}
