//
//  UserCardInfo.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/19/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse

class UserCardInfo: PFObject, PFSubclassing {
    @NSManaged var number: String
    @NSManaged var last4: String
    @NSManaged var expMonth: UInt
    @NSManaged var expYear: UInt
    @NSManaged var cvc: String
    @NSManaged var name: String
    @NSManaged var brandName: String
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
        return "UserCardInfo"
    }
    
}
