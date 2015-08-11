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
        tableView.registerNib(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
        tableView.estimatedRowHeight = 120
        
        loadCartDetails()
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
                                        
                                        for cartItem in self.cartItemList {
                                            println("\(cartItem.product.name) \(cartItem.product.stock)")
                                        }
                                        
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
}

extension CartViewController: UITableViewDelegate {
    
}


extension CartViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItemList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CartItemCell", forIndexPath: indexPath) as! CartItemCell
        let cartItem = cartItemList[indexPath.row]
        cell.cartItem = cartItem
        cell.itemImageView.file = cartItem.product.thumbnail
        
        cell.itemImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
            if error == nil {
                println("cell image loaded")
            } else {
                let errorString = error!.userInfo?["error"] as? String
                println(errorString)
            }
        })
        
        return cell
    }
}