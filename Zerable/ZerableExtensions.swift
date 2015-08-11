//
//  ZerableExtensions.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse

extension PFQuery {
    class func adjustCartItem(cart: PFObject, completion: (success: Bool, error: NSError?) ->()) {
        var cartItemsToDelete = [PFObject]()
        var cartItemToChangeQuantity = [PFObject]()
        
        let cartItemQuery = PFQuery(className: "CartItem")
        cartItemQuery.whereKey("cart", equalTo: cart)
        cartItemQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(success: false, error: error)
            } else {
                if let cartItems = objects as? [PFObject] {
                    for cartItem in cartItems {
                        let item = cartItem["item"] as! PFObject
                        let stock = (item["stock"] as! NSNumber).integerValue
                        let quantity = (cartItem["quantity"] as! NSNumber).integerValue
                        if stock == 0 {
                            cartItemsToDelete.append(item)
                        } else {
                            if quantity > stock {
                                cartItemToChangeQuantity.append(item)
                            }
                        }
                    }
                    
                    self.deleteCartItems(cartItemsToDelete, completion: {
                        (success, error) -> () in
                        if let error = error {
                            completion(success: false, error: error)
                        } else {
                            self.changeCartItemsQuantity(cartItemToChangeQuantity, completion: { (success, error) -> () in
                                if let error = error {
                                    completion(success: false, error: error)
                                } else {
                                    completion(success: true, error: error)
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    class func changeCartItemsQuantity(cartItems: [PFObject], completion: (success: Bool, error: NSError?) -> ()) {
        let cartItemsCount = cartItems.count
        
        if cartItemsCount == 0 {
            completion(success: true, error: nil)
        } else {
            var counter = 0
            for cartItem in cartItems {
                let stock = (cartItem["stock"] as! NSNumber).integerValue
                cartItem["quantity"] = stock
                cartItem.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        completion(success: false, error: error)
                    } else {
                        counter++
                        if counter == cartItemsCount {
                            completion(success: true, error: nil)
                        }
                    }
                })
            }
        }
    }
    
    class func deleteCartItems(cartItems: [PFObject], completion: (success: Bool, error: NSError?) -> ()) {
        if cartItems.count == 0 {
            completion(success: true, error: nil)
        } else {
            PFObject.deleteAllInBackground(cartItems, block: {
                (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    completion(success: false, error: error)
                } else {
                    completion(success: true, error: nil)
                }
            })
        }
    }
    
    class func addItemToCart(item: PFObject, completion: (success: Bool, error: NSError?) -> ()) {
        let cartQuery = PFQuery(className: "Cart")
        cartQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        cartQuery.whereKey("checkedOut", equalTo: false)
        cartQuery.limit = 1
        cartQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(success: false, error: error)
            } else {
                let results = objects as? [PFObject]
                // If no cart for current user was created
                if results!.count == 0 {
                    PFQuery.createCartWithItem(item, completion: {
                        (success, error) -> () in
                        if success {
                            completion(success: true, error: nil)
                        } else {
                            completion(success: false, error: error)
                        }
                    })
                }
                // If there was cart for current user created
                else if results!.count > 0 {
                    let cart = results!.first! as PFObject
                    // check if cart already contains the item
                    PFQuery.cartContainsItem(cart, item: item, completion: {
                        (contains, cartItem, error) -> () in
                        if let error = error {
                            completion(success: false, error: error)
                        } else {
                            if contains {
                                // If already contains the item, increase the quantity and save it
                                if let cartItem = cartItem {
                                    let quantity = (cartItem["quantity"] as! NSNumber).intValue
                                    let stock = (cartItem["stock"] as! NSNumber).intValue
                                    if quantity < stock {
                                        cartItem["quantity"] = Int(quantity) + 1
                                        cartItem.saveInBackgroundWithBlock({
                                            (success: Bool, error: NSError?) -> Void in
                                            if success {
                                                completion(success: true, error: nil)
                                            } else {
                                                completion(success: false, error: error)
                                            }
                                        })
                                    } else {
                                        completion(success: true, error: nil)
                                    }
                                }
                            } else {
                                // If not contains the item, create one with cart
                                PFQuery.createItemWithCart(item, cart: cart, completion: { (success, error) -> () in
                                    if success {
                                        completion(success: true, error: nil)
                                    } else {
                                        completion(success: false, error: error)
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    class func createCartWithItem(item: PFObject, completion: (success: Bool, error: NSError?) -> ()) {
        let cart = PFObject(className: "Cart")
        cart["checkedOut"] = false
        cart["user"] = PFUser.currentUser()!
        cart.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                self.createItemWithCart(item, cart: cart, completion: {
                    (success, error) -> () in
                    if success {
                        completion(success: true, error: nil)
                    } else {
                        completion(success: false, error: error)
                    }
                })
            }
        }
    }
    
    class func createItemWithCart(item: PFObject, cart: PFObject, completion: (success: Bool, error: NSError?) -> ()) {
        let cartItem = PFObject(className: "CartItem")
        cartItem["item"] = item
        cartItem["quantity"] = 1
        cartItem["cart"] = cart
        cartItem.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if success {
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        })
    }
    
    class func cartContainsItem(cart: PFObject, item: PFObject, completion: (contains: Bool, cartItem: PFObject?, error: NSError?) -> ()) {
        let cartItemQuery = PFQuery(className: "CartItem")
        cartItemQuery.whereKey("cart", equalTo: cart)
        cartItemQuery.whereKey("item", equalTo: item)
        cartItemQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(contains: false, cartItem: nil, error: nil)
            } else {
                if let cartItems = objects as? [PFObject] {
                    if cartItems.count > 0 {
                        let cartItem = cartItems.first! as PFObject
                        completion(contains: true, cartItem: cartItem, error: nil)
                    } else {
                        completion(contains: false, cartItem: nil, error: nil)
                    }
                }
            }
        }
    }
    
    
    class func loadImagesForItem(item: PFObject, completion: (itemImages: [ItemPhoto]?, error: NSError?) -> ()) {
        let query = PFQuery(className: "ImageFile")
        query.whereKey("product", equalTo: item)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                completion(itemImages: nil, error: error)
            } else {
                if let images = objects as? [PFObject] {
                    var files = [PFFile]()
                    for image in images {
                        files.append(image["imageFile"] as! PFFile)
                    }
                    self.loadImageData(files, item: item, completion: {
                        (itemImages, error) -> () in
                        if error == nil {
                            if let itemImages = itemImages {
                                completion(itemImages: itemImages, error: nil)
                            }
                        } else {
                            completion(itemImages: nil, error: error)
                        }
                    })
                }
            }
        }
    }
    
    class func loadImageData(files: [PFFile], item: PFObject, completion:(itemImages: [ItemPhoto]?, error: NSError?) -> ()) {
        var loadCount = 0
        var imageCount = files.count
        var itemImages = [ItemPhoto]()
        for file in files {
            file.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        let title = NSAttributedString(string: item["name"] as! String, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
                        let itemImage = ItemPhoto(image: image, attributedCaptionTitle: title)
                        itemImages.append(itemImage)
                        loadCount++
                        if loadCount == imageCount {
                            completion(itemImages: itemImages, error:nil)
                        }
                    }
                } else {
                    completion(itemImages: nil, error: error)
                }
            })
        }
    }

}

extension UIView {
    class func applyCurvedShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.moveToPoint(CGPoint(x: radius, y: height))
        
        // top right
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurveToPoint(CGPoint(x: radius, y: height + depth),
            controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
            controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        let layer = view.layer
        layer.shadowPath = path.CGPath
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
}

extension UIColor {
    class func imageWithColor(color :UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(
            red: CGFloat(r / 255.0),
            green: CGFloat(g / 255.0),
            blue:CGFloat(b / 255.0),
            alpha: CGFloat(alpha))
    }
}

extension UIImage {
    func newImageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension String {
    
    func rangesOfString(findStr:String) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if contains(self, first(findStr)!) {
            // if so set this as the place to start searching
            startInd = find(self,first(findStr)!)!
        }
        else {
            // if not return empty array
            return arr
        }
        var i = distance(self.startIndex, startInd)
        while i<=count(self)-count(findStr) {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+count(findStr))] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+count(findStr))))
                i = i+count(findStr)-1
                // check again for first occurrence of character (this reduces number of times loop will run
                if contains(self[advance(self.startIndex, i)..<self.endIndex], first(findStr)!) {
                    // if so set this as the place to start searching
                    i = distance(self.startIndex,find(self[advance(self.startIndex, i)..<self.endIndex],first(findStr)!)!) + i
                    count(findStr)
                }
                else {
                    return arr
                }
                
            }
            i++
        }
        return arr
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func welcomeViewController() -> WelcomeViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("WelcomeViewController") as!
        WelcomeViewController
    }

    class func loginlViewController() -> LoginViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }
    
    class func signupViewController() -> SignupViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
    }
    
    class func termAndPolicyViewController() -> TermAndPolicyViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("TermAndPolicyViewController") as! TermAndPolicyViewController
    }
    
    class func itemListViewController() -> ItemListViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ItemListViewController") as! ItemListViewController
    }
    
    class func settingsViewController() -> SettingsViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
    }
    
    class func profileViewController() -> ProfileViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
    }
    
    
    class func basicViewController() -> BasicInfoViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("BasicInfoViewController") as! BasicInfoViewController
    }
    
    class func addressViewController() -> AddressViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("AddressViewController") as! AddressViewController
    }
    
    class func paymentInfoViewController() -> PaymentInfoViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("PaymentInfoViewController") as! PaymentInfoViewController
    }
    
    class func itemDetailViewController() -> ItemDetailViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ItemDetailViewController") as! ItemDetailViewController
    }
    
    class func cartViewController() -> CartViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CartViewController") as! CartViewController
    }
}

extension KeychainWrapper {
    
    class var sharedInstance: KeychainWrapper {
        struct Static {
            static let instance: KeychainWrapper = KeychainWrapper()
        }
        return Static.instance
    }
}

