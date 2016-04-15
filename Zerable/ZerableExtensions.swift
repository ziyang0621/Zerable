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
    
    class func retrieveOrderHistory(user: PFUser, completion: (orderHistoryList: [Order: [CartItem]]?, error: NSError?) ->  ()) {
        var returnList = [Order: [CartItem]]()
        let orderQuery = PFQuery(className: "Order")
        orderQuery.whereKey("user", equalTo: user)
        orderQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(orderHistoryList: nil, error: error)
            } else {
                if let returnOrders = objects as? [Order] {
                    var orderCounter = 0
                    let orderCount = returnOrders.count
                    if orderCount == 0 {
                        completion(orderHistoryList: returnList, error: nil)
                    } else {
                        for order in returnOrders {
                            self.retrieveCartItemsForCart(order.cart, completion: { (cartItems, error) -> () in
                                if let error = error {
                                    completion(orderHistoryList: nil, error: error)
                                } else {
                                    if let cartItems = cartItems {
                                        returnList[order] = cartItems
                                        orderCounter++
                                        if orderCounter == orderCount {
                                            completion(orderHistoryList: returnList, error: nil)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    class func saveOrder(cart: Cart, order: Order,completion: (success: Bool, error: NSError?) -> ()) {
        
        cart.checkedOut = true
        cart.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if let error = error {
                completion(success: false, error: error)
            } else {
                order.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        completion(success: false, error: error)
                    } else {
                        completion(success: true, error: nil)
                    }
                })
            }
        }
    }
        
    class func loadUserPayment(user: PFUser, completion: (cardInfo: UserCardInfo?, error: NSError?) -> ()) {
        let query = PFQuery(className: "UserCardInfo")
        query.whereKey("user", equalTo: user)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(cardInfo: nil, error: error)
            } else {
                if let cardInfos = objects as? [UserCardInfo] {
                    if cardInfos.count > 0 {
                        completion(cardInfo: cardInfos.first!, error: nil)
                    } else {
                        completion(cardInfo: nil, error: nil)
                    }
                }
            }
        }
    }
    
    class func updateCardItemsProductStock(cartItems: [CartItem], completion: (success: Bool, error: NSError?) -> ()) {
        var counter = 0
        let cartItemCount = cartItems.count
        for singleItem in cartItems {
            singleItem.product.stock = singleItem.product.stock - singleItem.quantity
            singleItem.product.saveInBackgroundWithBlock({
                (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    completion(success: false, error: error)
                } else {
                    counter++
                    if counter == cartItemCount {
                        completion(success: true, error: nil)
                    }
                }
            })
        }
    }
    
    class func updateCartItems(cartItems: [CartItem], completion: (success: Bool, error: NSError?) -> ()) {
       var counter = 0
       let cartItemCount = cartItems.count
        for singleItem in cartItems {
            singleItem.saveInBackgroundWithBlock({
                (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    completion(success: false, error: error)
                } else {
                    counter++
                    if counter == cartItemCount {
                        completion(success: true, error: nil)
                    }
                }
            })
        }
    }
    
    class func adjustCartItem(cart: Cart, completion: (success: Bool, error: NSError?) ->()) {
        let cartItemQuery = PFQuery(className: "CartItem")
        cartItemQuery.whereKey("cart", equalTo: cart)
        cartItemQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(success: false, error: error)
            } else {
                if let cartItems = objects as? [CartItem] {
                    if cartItems.count == 0 {
                        completion(success: true, error: nil)
                    } else {
                        PFQuery.checkCartItemsToChange(cartItems, completion: {
                            (cartItemsToDelete, cartItemsToChangeQuantity, error) -> () in
                            if let error = error {
                                completion(success: false, error: error)
                            } else {
                                if let itemsToDelete = cartItemsToDelete {
                                    self.deleteCartItems(itemsToDelete, completion: { (success, error) -> () in
                                        if let error = error {
                                            completion(success: false, error: error)
                                        } else {
                                            if let itemsToChangeQuantity = cartItemsToChangeQuantity {
                                                self.changeCartItemsQuantity(itemsToChangeQuantity, completion: { (success, error) -> () in
                                                    if let error = error {
                                                        completion(success: false, error: error)
                                                    } else {
                                                        completion(success: true, error: error)
                                                    }
                                                })
                                            }
                                        }
                                        
                                    })
                                }
                            }
                        })

                    }
                }
            }
        }
    }
    
    class func checkCartItemsToChange(cartItems: [CartItem], completion: (cartItemsToDelete: [CartItem]?, cartItemsToChangeQuantity: [CartItem]?, error: NSError?) -> ()) {
        var counter = 0
        let cartItemCount = cartItems.count
        var cartItemsToDelete = [CartItem]()
        var cartItemsToChangeQuantity = [CartItem]()

        for cartItem in cartItems {
            let quantity = cartItem.quantity
            PFQuery.fetchProductStock(cartItem.product, completion: {
                (stock, error) -> () in
                counter++
                if let error = error {
                    completion(cartItemsToDelete: nil, cartItemsToChangeQuantity: nil, error: error)
                } else {
                    if stock == 0 || quantity == 0 {
                        cartItemsToDelete.append(cartItem)
                    } else {
                        if quantity > stock {
                            cartItemsToChangeQuantity.append(cartItem)
                        }
                    }
                }
                if counter == cartItemCount {
                    completion(cartItemsToDelete: cartItemsToDelete, cartItemsToChangeQuantity: cartItemsToChangeQuantity, error: nil)
                }
            })
        }
    }
    
    class func changeCartItemsQuantity(cartItems: [CartItem], completion: (success: Bool, error: NSError?) -> ()) {
        let cartItemsCount = cartItems.count
        
        if cartItemsCount == 0 {
            completion(success: true, error: nil)
        } else {
            var counter = 0
            for cartItem in cartItems {
                PFQuery.fetchProductStock(cartItem.product, completion: {
                    (stock, error) -> () in
                    if let error = error {
                        completion(success: false, error: error)
                    } else {
                        cartItem.quantity = stock
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
                })
            }
        }
    }
    
    class func deleteCartItems(cartItems: [CartItem], completion: (success: Bool, error: NSError?) -> ()) {
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
    
    class func fetchProductStock(product: Product, completion: (stock: Int, error: NSError?) ->()) {
        product.fetchIfNeededInBackgroundWithBlock {
            (object, error) -> Void in
            if let error = error {
                completion(stock: 0, error: error)
            } else {
                if let prod = object as? Product {
                    completion(stock: prod.stock, error: nil)
                }
            }
        }
    }
    
    class func fetchCartItemsProductDetails(cartItems: [CartItem], completion: (cartItems: [CartItem]?, error: NSError?) -> ()) {
        var counter = 0
        let cartItemCount = cartItems.count
        
        for cartItem in cartItems {
            cartItem.product.fetchIfNeededInBackgroundWithBlock({
                (object, error) -> Void in
                if let error = error {
                    completion(cartItems: nil, error: error)
                } else {
                    if let product = object as? Product {

                        cartItem.product = product
                        counter++
                        if counter == cartItemCount {
                            completion(cartItems: cartItems, error: nil)
                        }
                    }
                }
            })
        }
    }
    
    class func retrieveCartItemsForCart(cart: Cart, completion: (cartItems: [CartItem]?, error: NSError?) -> ()) {
        let cartItemQuery = PFQuery(className: "CartItem")
        cartItemQuery.whereKey("cart", equalTo: cart)
        cartItemQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(cartItems: nil, error: error)
            } else {
                if let cartItems = objects as? [CartItem] {
                    if cartItems.count == 0 {
                        completion(cartItems: cartItems, error: nil)
                    } else {
            
                        self.fetchCartItemsProductDetails(cartItems, completion: { (cartItems, error) -> () in
                            if let error = error {
                                completion(cartItems: nil, error: error)
                            } else {
                                completion(cartItems: cartItems, error: nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    class func checkIfCartIsEmpty(completion: (cart: Cart?, error: NSError?) ->()) {
        let cartQuery = PFQuery(className: "Cart")
        cartQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        cartQuery.whereKey("checkedOut", equalTo: false)
        cartQuery.limit = 1
        cartQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completion(cart: nil, error: error)
            } else {
                let results = objects as? [Cart]
                if results!.count == 0 {
                    completion(cart: nil, error: nil)
                } else {
                    let cart = results!.first! as Cart
                    completion(cart: cart, error: nil)
                }
            }
        }
    }
    
    class func addProductToCart(product: Product, completion: (success: Bool, error:
        NSError?) -> ()) {
      
        PFQuery.checkIfCartIsEmpty {
            (cart, error) -> () in
            
            if let error = error {
                completion(success: false, error: error)
            } else {
                // If there was no cart created, then create one witha the product
                if cart == nil {
                    PFQuery.createCartWithProduct(product, completion: {
                        (success, error) -> () in
                        if success {
                            completion(success: true, error: nil)
                        } else {
                            completion(success: false, error: error)
                        }
                    })
                }
                // If there was cart for current user created
                else {
                    PFQuery.cartContainsProduct(cart!, product: product, completion: {
                        (contains, cartItem, error) -> () in
                        if let error = error {
                            completion(success: false, error: error)
                        } else {
                            if contains {
                                // If already contains the product, increase the quantity and save it
                                if let cartItem = cartItem {
                                    let quantity = cartItem.quantity
                                    PFQuery.fetchProductStock(cartItem.product, completion: {
                                        (stock, error) -> () in
                                        if let error = error {
                                            completion(success: false, error: error)
                                        } else {
                                            if quantity < stock {
                                                cartItem.quantity = quantity + 1
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
                                    })
                                }
                            } else {
                                // If not contains the product, create one with cart
                                PFQuery.createProductWithCart(product, cart: cart!, completion: { (success, error) -> () in
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
    
    class func createCartWithProduct(product: Product, completion: (success: Bool, error: NSError?) -> ()) {
        let cart = Cart()
        cart.checkedOut = false
        cart.user = PFUser.currentUser()!
        cart.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                self.createProductWithCart(product, cart: cart, completion: {
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
    
    class func createProductWithCart(product: Product, cart: Cart, completion: (success: Bool, error: NSError?) -> ()) {
        let cartItem = CartItem()
        cartItem.product = product
        cartItem.quantity = 1
        cartItem.cart = cart
        cartItem.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if success {
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        })
    }
    
    class func cartContainsProduct(cart: Cart, product: Product, completion: (contains: Bool, cartItem: CartItem?, error: NSError?) -> ()) {
        let cartItemQuery = PFQuery(className: "CartItem")
        cartItemQuery.whereKey("cart", equalTo: cart)
        cartItemQuery.whereKey("product", equalTo: product)
        cartItemQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                completion(contains: false, cartItem: nil, error: nil)
            } else {
                if let cartItems = objects as? [CartItem] {
                    if cartItems.count > 0 {
                        let cartItem = cartItems.first! as CartItem
                        completion(contains: true, cartItem: cartItem, error: nil)
                    } else {
                        completion(contains: false, cartItem: nil, error: nil)
                    }
                }
            }
        }
    }
    
    
    class func loadImagesForProduct(product: Product, completion: (itemImages: [ItemPhoto]?, error: NSError?) -> ()) {
        let query = PFQuery(className: "ImageFile")
        query.whereKey("product", equalTo: product)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                completion(itemImages: nil, error: error)
            } else {
                if let images = objects {
                    var files = [PFFile]()
                    for image in images {
                        files.append(image["imageFile"] as! PFFile)
                    }
                    self.loadImageData(files, product: product, completion: {
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
    
    class func loadImageData(files: [PFFile], product: Product, completion:(itemImages: [ItemPhoto]?, error: NSError?) -> ()) {
        var loadCount = 0
        let imageCount = files.count
        var itemImages = [ItemPhoto]()
        for file in files {
            file.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        let title = NSAttributedString(string: product.name, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
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
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

//extension String {
//    
//    func rangesOfString(findStr:String) -> [Range<String.Index>] {
//        var arr = [Range<String.Index>]()
//        var startInd = self.startIndex
//        // check first that the first character of search string exists
//        if contains(self, first(findStr)!) {
//            // if so set this as the place to start searching
//            startInd = find(self,first(findStr)!)!
//        }
//        else {
//            // if not return empty array
//            return arr
//        }
//        var i = distance(self.startIndex, startInd)
//        while i<=count(self)-count(findStr) {
//            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+count(findStr))] == findStr {
//                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+count(findStr))))
//                i = i+count(findStr)-1
//                // check again for first occurrence of character (this reduces number of times loop will run
//                if contains(self[advance(self.startIndex, i)..<self.endIndex], first(findStr)!) {
//                    // if so set this as the place to start searching
//                    i = distance(self.startIndex,find(self[advance(self.startIndex, i)..<self.endIndex],first(findStr)!)!) + i
//                    count(findStr)
//                }
//                else {
//                    return arr
//                }
//                
//            }
//            i++
//        }
//        return arr
//    }
//}

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
    
    class func productListViewController() -> ProductListViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ProductListViewController") as! ProductListViewController
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
    
    class func productDetailViewController() -> ProductDetailViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ProductDetailViewController") as! ProductDetailViewController
    }
    
    class func cartViewController() -> CartViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CartViewController") as! CartViewController
    }
    
    class func orderSummaryViewController() -> OrderSummaryViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("OrderSummaryViewController") as! OrderSummaryViewController
    }
    
    class func orderCompletedViewController() -> OrderCompletedViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("OrderCompletedViewController") as! OrderCompletedViewController
    }
    
    class func orderHistoryViewController() -> OrderHistoryViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("OrderHistoryViewController") as! OrderHistoryViewController
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


extension Int {

    public static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }

    public static func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}

extension Double {

    public static func random() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    public static func random(min: Double, max: Double) -> Double {
        return Double.random() * (max - min) + min
    }
}

extension Float {
   
    public static func random() -> Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }

    public static func random(min: Float, max: Float) -> Float {
        return Float.random() * (max - min) + min
    }
}

extension CGFloat {
  
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}
