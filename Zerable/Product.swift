//
//  Product.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/11/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse

class Product: PFObject, PFSubclassing {
    @NSManaged var name: String
    @NSManaged var productdescription: String
    @NSManaged var price: Double
    @NSManaged var stock: Int
    @NSManaged var category: String
    @NSManaged var origin: String
    @NSManaged var storedMethod: String
    @NSManaged var durability: Int
    @NSManaged var certificate: String
    @NSManaged var productionDate: String
    @NSManaged var thumbnail: PFFile
    
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Product"
    }
}
