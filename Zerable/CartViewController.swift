//
//  CartViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse
import KVNProgress

class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var cartItemList = [CartItem]()
    var cart: Cart?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Cart"
        
        let leftBarButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeButtonTapped")
        navigationItem.leftBarButtonItem = leftBarButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
        tableView.registerNib(UINib(nibName: "SubtotalCell", bundle: nil), forCellReuseIdentifier: "SubtotalCell")
        tableView.estimatedRowHeight = 120
        
        loadCartDetails()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadCartDetails() {
        KVNProgress.showWithStatus("Loading...", onView: navigationController?.view)
        cartItemList.removeAll(keepCapacity: false)
        
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
                                        self.cartItemList.extend(cartItems)
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                            })

                        }
                    })
                    
                } else {
                    KVNProgress.dismiss()

                    // cart is empty
                }
            }
        }
    }
    
    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateSubtotal() -> Double {
        var subTotal: Double = 0.0
        for cartItem in cartItemList {
            let itemTotal = cartItem.product.price * Double(cartItem.quantity)
            subTotal += itemTotal
        }
        
        return subTotal
    }
}

extension CartViewController: UITableViewDelegate {
    
}

extension CartViewController: CartItemCellDelegate {
    func cartItemCellDidChangeQuantity(cell: CartItemCell, quantity: Int) {
        
        for index in 0..<cartItemList.count {
            if cartItemList[index].product.objectId == cell.cartItem!.product.objectId {
                cartItemList[index].quantity = quantity
                break
            }
        }
        
        let indexPath = NSIndexPath(forRow: cartItemList.count, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}


extension CartViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < cartItemList.count {
            return 120
        }
        return 44
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cartItemList.count > 0 {
            return cartItemList.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < cartItemList.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("CartItemCell", forIndexPath: indexPath) as! CartItemCell
            let cartItem = cartItemList[indexPath.row]
            cell.cartItem = cartItem
            cell.itemImageView.file = cartItem.product.thumbnail
            cell.delegate = self
            
            cell.itemImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    println("cell image loaded")
                } else {
                    let errorString = error!.userInfo?["error"] as? String
                    println(errorString)
                }
            })
            
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SubtotalCell", forIndexPath: indexPath) as! SubtotalCell
            cell.subtotalLabel.text = formattedCurrencyString(calculateSubtotal())
            return cell
        }
    }
}