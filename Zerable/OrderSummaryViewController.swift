//
//  OrderSummaryViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/24/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import KVNProgress
import Parse
import Stripe
import Alamofire

class OrderSummaryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cartEmptyLabel: UILabel!
    @IBOutlet weak var placeOrderView: UIView!
    
    var cartItemList = [CartItem]()
    var cart: Cart?
    var cardInfo: UserCardInfo?
    var selectedPlacemark: CLPlacemark?
    var loadedAddressSummary = ""
    var cardInfoText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Order Summary"
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
        tableView.registerNib(UINib(nibName: "TotalCell", bundle: nil), forCellReuseIdentifier: "TotalCell")
        tableView.registerNib(UINib(nibName: "UserAddressCell", bundle: nil), forCellReuseIdentifier: "UserAddressCell")
        tableView.registerNib(UINib(nibName: "PaymentInfoCell", bundle: nil), forCellReuseIdentifier: "PaymentInfoCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        let placeOrderTap = UITapGestureRecognizer(target: self, action: "placeOrder")
        placeOrderView.addGestureRecognizer(placeOrderTap)
        
        loadOrderSummaryDetails()
    }
    
    func placeOrder() {
        KVNProgress.showWithStatus("Placing order...", onView: navigationController?.view)
        
        PFQuery.checkCartItemsToChange(cartItemList, completion: {
            (cartItemsToDelete, cartItemsToChangeQuantity, error) -> () in
            if let error = error {
                KVNProgress.dismiss()
                let errorString = error.userInfo?["error"] as? String
                let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)            } else {
                if cartItemsToDelete!.count > 0 || cartItemsToChangeQuantity!.count > 0 {
                    let alert = UIAlertController(title: "Error", message: "Some of the items do not have enough stock, please change the quantity", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    println("enough quantity")
                    PFQuery.updateCardItemsProductStock(self.cartItemList, completion: { (success, error) -> () in
                        if let error = error {
                            KVNProgress.dismiss()
                            let alert = UIAlertController(title: "Error", message: "unable to update product stock", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            self.startStripePayment()
                        }
                    })
                }
            }
        })
    }
    
    func startStripePayment(isTest: Bool = true) {
        
        let stripCard = STPCard()
        if isTest {
            stripCard.number = "4242424242424242"
            stripCard.cvc = "222"
            stripCard.expMonth = 9
            stripCard.expYear = 2019

        } else {
            stripCard.number = cardInfo!.number
            stripCard.cvc = cardInfo!.cvc
            stripCard.expMonth = cardInfo!.expMonth
            stripCard.expYear = cardInfo!.expYear
        }
     
        STPAPIClient.sharedClient().createTokenWithCard(stripCard, completion: { (token, error) -> Void in
            
            if error != nil {
                self.handleError(error!)
                return
            }
            
            self.postStripeToken(token!)
        })
    }
    
    func postStripeToken(token: STPToken) {
        
        let URL = "http://localhost/donate/payment.php"
        let params = ["stripeToken": token.tokenId,
            "amount": calculateSubtotal().doubleValue,
            "currency": "usd",
            "description": PFUser.currentUser()!.email!]
        
        Alamofire.request(.POST, URL, parameters: params as? [String : AnyObject]).response {
            (request, response, data, error) in
            if let error = error {
                self.handleError(error)
            } else {
                if let data = data {
                    var dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! [String: String]
                    let status = dict["status"]
                    if status == "Failure" {
                        KVNProgress.dismiss()
                        UIAlertView(title: status,
                            message: dict["message"],
                            delegate: nil,
                            cancelButtonTitle: "OK").show()
                    } else if status == "Success" {
                        println("payment submitted")
                        self.saveOrderInParse()
                    }
                } else {
                    KVNProgress.dismiss()
                    UIAlertView(title: "Error",
                        message: "Server error",
                        delegate: nil,
                        cancelButtonTitle: "OK").show()
                }
            }
        }
    }
    
    func handleError(error: NSError) {
        KVNProgress.dismiss()
        UIAlertView(title: "Please Try Again",
            message: error.localizedDescription,
            delegate: nil,
            cancelButtonTitle: "OK").show()
    }

    func saveOrderInParse() {

        cart!.checkedOut = true
        cart!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if let error = error {
                KVNProgress.dismiss()
                let alert = UIAlertController(title: "Error", message: "unable to update cart", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                
                let order = Order()
                order.user = PFUser.currentUser()!
                order.status = "orderPlaced"
                order.cardInfo = self.cardInfo!
                order.addressSummary = self.loadedAddressSummary
                order.placeMark =  NSKeyedArchiver.archivedDataWithRootObject(self.selectedPlacemark!)
                order.cart = self.cart!
                
                order.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    KVNProgress.dismiss()
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: "unable to place order", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        println("order placed")
                        let orderCompletedVC = UIStoryboard.orderCompletedViewController()
                        let orderCompletedNav = UINavigationController(rootViewController: orderCompletedVC)
                        self.presentViewController(orderCompletedNav, animated: true, completion: nil)
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserAddress() {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "UserAddress")
            query.whereKey("user", equalTo: currentUser)
            query.orderByDescending("createdAt")
            query.getFirstObjectInBackgroundWithBlock({
                (address: PFObject?, error:NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                    println(errorString)
                } else {
                    self.loadedAddressSummary = address!["addressSummary"] as! String
                    self.selectedPlacemark =  NSKeyedUnarchiver.unarchiveObjectWithData(address!["placeMark"] as! NSData) as? CLPlacemark
                    self.placeOrderView.alpha = 1
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func loadOrderSummaryDetails() {
        KVNProgress.showWithStatus("Loading...", onView: navigationController?.view)
        cartItemList.removeAll(keepCapacity: false)
        cartEmptyLabel.alpha = 0
        placeOrderView.alpha = 0
        
        PFQuery.checkIfCartIsEmpty { 
            (cart, error) -> () in
            if let error = error {
                KVNProgress.dismiss()
                let errorString = error.userInfo?["error"] as? String
                println(errorString)
            } else {
                if let cart = cart {
                    self.cart = cart
                    
                    PFQuery.adjustCartItem(cart, completion: {
                        (success, error) -> () in
                        if let error = error {
                            KVNProgress.dismiss()
                            let errorString = error.userInfo?["error"] as? String
                            println(errorString)
                        } else {
                            
                            PFQuery.retrieveCartItemsForCart(cart, completion: {
                                (cartItems, error) -> () in
                                KVNProgress.dismiss()
                                if let error = error {
                                    let errorString = error.userInfo?["error"] as? String
                                    println(errorString)
                                } else {
                                    if let cartItems = cartItems {
                                        if cartItems.count > 0 {
                                            self.cartItemList.extend(cartItems)
                                            self.loadUserAddress()
                                        } else {
                                            self.cartEmptyLabel.alpha = 1
                                            self.tableView.alpha = 0
                                        }
                                    }
                                }
                            })
                            
                        }
                    })
                    
                } else {
                    KVNProgress.dismiss()
                    self.cartEmptyLabel.alpha = 1
                    self.tableView.alpha = 0
                }
            }
        }
    }

    
    func calculateSubtotal() -> NSDecimalNumber {
        var subTotal = NSDecimalNumber(string: "0.00")
        for cartItem in cartItemList {
            let itemSubtotal = NSDecimalNumber(decimal: cartItem.product.price.decimalValue).decimalNumberByMultiplyingBy(NSDecimalNumber(decimal: NSNumber(double: Double(cartItem.quantity)).decimalValue))
            subTotal = subTotal.decimalNumberByAdding(itemSubtotal)
        }
        
        return subTotal
    }

}

extension OrderSummaryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row < cartItemList.count {
                return 120
            }
            return 44
        }
        return UITableViewAutomaticDimension
    }
}

extension OrderSummaryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row < cartItemList.count {
                return 120
            }
            return 44
        }
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cartItemList.count + 1
        }
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Items"
        } else if section == 1 {
            return "Payment"
        } else {
            return "Shipping address"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row < cartItemList.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("CartItemCell", forIndexPath: indexPath) as! CartItemCell
                let cartItem = cartItemList[indexPath.row]
                cell.cartItem = cartItem
                cell.itemImageView.file = cartItem.product.thumbnail
                cell.plusButton.alpha = 0
                cell.minusButton.alpha = 0
                
                cell.itemImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                    if error == nil {
                        // println("cell image loaded")
                    } else {
                        let errorString = error!.userInfo?["error"] as? String
                        println(errorString)
                    }
                })
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("TotalCell", forIndexPath: indexPath) as! TotalCell
                cell.totalLabel.text = formattedCurrencyString(calculateSubtotal())
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PaymentInfoCell", forIndexPath: indexPath) as! PaymentInfoCell
            cell.paymentInfoLabel.text = cardInfoText
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserAddressCell", forIndexPath: indexPath) as! UserAddressCell
            cell.addressLabel.text = loadedAddressSummary
            return cell
        }
    }
}
