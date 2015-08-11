//
//  Cart.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/11/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse

class Cart: PFObject, PFSubclassing {
    @NSManaged var checkedOut: Bool
    @NSManaged var user: PFUser
    
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Cart"
    }
}
