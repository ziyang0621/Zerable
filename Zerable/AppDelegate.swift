//
//  AppDelegate.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/22/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse

let kThemeColor = UIColor.colorWithRGBHex(0x71EAC6, alpha: 1.0)
let kItemList = ["frozen-beef", "frozen-red-meat", "frozen-pork", "frozen-shrimp", "frozen-chicken"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("gSMFL1BfYtr0daSJz9iQqUCzsK7ZRYdSg80Fy30O", clientKey: "R4s5wWFQus4BPt1xaKnIyOHPPLSSIa9gd7fS3YbQ")
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = titleDict as [NSObject : AnyObject]
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
        UINavigationBar.appearance().setBackgroundImage(UIColor.imageWithColor(kThemeColor), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIColor.imageWithColor(kThemeColor)
        UINavigationBar.appearance().translucent = true
        
        if PFUser.currentUser() != nil {
            if let window = self.window {
                let itemListVC = UIStoryboard.itemListViewController()
                itemListVC.fromGridIndex = -1
                let itemListNav = UINavigationController(rootViewController: itemListVC)
                window.rootViewController = itemListNav
            }
        }
        
        checkProducts()
       
        return true
    }
    
    func checkProducts() {
        let query = PFQuery(className: "Product")
        query.limit = 1
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? String
                println(errorString)
            } else {
                if let products = objects as? [PFObject] {
                    if products.count == 0 {
                        self.insertProducts()
                    }
                }
            }
        }
    }
    
    func insertProducts() {
        for index in 0..<15 {
            let product = PFObject(className: "Product")
            product["name"] = shuffle(kItemList).first
            product["description"] = "This is a frozen meet from Bay Area"
            product["price"] = Int(arc4random_uniform(100))
            product["stock"] = Int(arc4random_uniform(100))
            product["category"] = "American"
            product["origin"] = "San Francisco"
            product["storeMethod"] = "Frozen"
            product["durability"] = 180
            product["certificate"] = "xxx supply"
            product["productionDate"] = "7/1/2015"
            product["thumbnail"] = generateImage()
        
            product.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                } else {
                    println("inserted product")
                    self.addProductImage(product)
                }
            })
        }
    }
    
    func addProductImage(product: PFObject) {
        
        for imageIndex in 0..<3 {
            let detailImage = PFObject(className: "ImageFile")
            detailImage["imageType"] = "detailImage"
            detailImage["imageFile"] = generateImage()
            detailImage["product"] = product
            detailImage.saveInBackgroundWithBlock {   (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                } else {
                    println("saved detail image")
                }
            }
        }
    }
    
    func generateImage() -> PFFile {
        let imageName = shuffle(kItemList).first
        let imageData = UIImagePNGRepresentation(UIImage(named: imageName!))
        let imageFile = PFFile(name: imageName, data: imageData)
        return imageFile
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

