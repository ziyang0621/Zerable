//
//  Order.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse

class Order: PFObject, PFSubclassing {
    @NSManaged var user: PFUser
    @NSManaged var status: String
    @NSManaged var cardInfo: UserCardInfo
    @NSManaged var addressSummary: String
    @NSManaged var placeMark: NSData
    @NSManaged var cart: Cart
    @NSManaged var total: NSDecimalNumber
    @NSManaged var shippingFee: NSDecimalNumber
    
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Order"
    }

}
