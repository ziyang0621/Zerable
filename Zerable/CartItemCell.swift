//
//  CartItemCell.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import ParseUI

protocol CartItemCellDelegate {
    func cartItemCellDidChangeQuantity(cell: CartItemCell, quantity: Int)
}


class CartItemCell: PFTableViewCell {

    @IBOutlet weak var itemImageView: PFImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var delegate: CartItemCellDelegate?
    
    var cartItem: CartItem? {
        didSet {
            if let cartItem = cartItem {
                itemNameLabel.text = cartItem.product.name
                stockLabel.text = "In Stock: \(cartItem.product.stock)"
                currentQuantity = cartItem.quantity
            }
        }
    }
    
    var currentQuantity: Int? {
        didSet {
            if let currentQuantity = currentQuantity {
                quantityLabel.text = "\(currentQuantity)"
                let total = cartItem!.product.price * Double(currentQuantity)
                priceLabel.text = formattedCurrencyString((total as NSNumber))
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
        if currentQuantity > 0 {
            currentQuantity!--
            delegate?.cartItemCellDidChangeQuantity(self, quantity: currentQuantity!)
        }
    }
    
    @IBAction func plusButtonTapped(sender: AnyObject) {
        if let cartItem = cartItem {
            if currentQuantity < cartItem.product.stock {
                currentQuantity!++
                delegate?.cartItemCellDidChangeQuantity(self, quantity: currentQuantity!)
            }
        }
    }
}
