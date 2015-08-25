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
import RNGridMenu

class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cartEmptyLabel: UILabel!
    @IBOutlet weak var processToCheckoutView: UIView!
    @IBOutlet weak var assistButton: UIButton!
    var cartItemList = [CartItem]()
    var cart: Cart?
    var fromGridIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Cart"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
        tableView.registerNib(UINib(nibName: "TotalCell", bundle: nil), forCellReuseIdentifier: "TotalCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        let processTap = UITapGestureRecognizer(target: self, action: "processToCheckout")
        processToCheckoutView.addGestureRecognizer(processTap)
        
        UIView.applyCurvedShadow(assistButton.imageView!)
    }
    
    func processToCheckout() {
        println("process tapped")
        let basicInfoVC = UIStoryboard.basicViewController()
        basicInfoVC.toCheckout = true
        viewControllerTransitionWithSaving(false, destVC: basicInfoVC, showVC: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if fromGridIndex == -1 {
            let leftBarButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeButtonTapped")
            navigationItem.leftBarButtonItem = leftBarButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        if fromGridIndex == -1 {
            assistButton.alpha = 0
        } else {
            assistButton.alpha = 1
        }

        loadCartDetails()
    }
    
    func loadCartDetails() {
        KVNProgress.showWithStatus("Loading...", onView: navigationController?.view)
        cartItemList.removeAll(keepCapacity: false)
        cartEmptyLabel.alpha = 0
        processToCheckoutView.alpha = 0
    
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
                                            self.processToCheckoutView.alpha = 1
                                        } else {
                                            self.cartEmptyLabel.alpha = 1
                                        }
                                        self.tableView.reloadData()
                                    }
                                }
                            })

                        }
                    })
                    
                } else {
                    KVNProgress.dismiss()
                    self.cartEmptyLabel.alpha = 1
                }
            }
        }
    }
    
    func viewControllerTransitionWithSaving(dismiss: Bool, destVC: UIViewController?, showVC: Bool = false) {
        if self.cartItemList.count > 0 {
            KVNProgress.showWithStatus("Saving changes...", onView: self.navigationController?.view)
            PFQuery.updateCartItems(self.cartItemList, completion: {
                (success, error) -> () in
                KVNProgress.dismiss()
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                    println(errorString)
                } else {
                    if dismiss {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        if showVC {
                            self.showViewController(destVC!, sender: self)
                        } else {
                              self.presentViewController(destVC!, animated: true, completion: nil)
                        }
                    }
                }
            })
        } else {
            if dismiss {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.presentViewController(destVC!, animated: true, completion: nil)
            }
        }
    }
    
    func closeButtonTapped() {
        viewControllerTransitionWithSaving(true, destVC: nil)
    }

    @IBAction func assistButtonPressed(sender: AnyObject) {
        let gridMenu = RNGridMenu(images: [UIImage(named: "home")!.newImageWithColor(kThemeColor),
            UIImage(named: "shopping")!.newImageWithColor(kThemeColor),
            UIImage(named: "history")!.newImageWithColor(kThemeColor),
            UIImage(named:"settings")!.newImageWithColor(kThemeColor)])
        
        gridMenu.delegate = self
        gridMenu.showInViewController(navigationController, center: CGPoint(x: CGRectGetWidth(view.frame)/2, y: CGRectGetHeight(view.frame)/2))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension CartViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < cartItemList.count {
            return 120
        }
        return 44
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
    }
}

extension CartViewController: RNGridMenuDelegate {
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
        delay(seconds: 0.3) { () -> () in
            println("test inside")
            if itemIndex == 1 {
                return
            }
            if itemIndex == self.fromGridIndex {
                self.viewControllerTransitionWithSaving(true, destVC: nil)
            }
            else {
                var destinationVC: UINavigationController?
                if itemIndex == 0 {
                    let productListVC = UIStoryboard.productListViewController()
                    productListVC.fromGridIndex == 1
                    let productListNav = UINavigationController(rootViewController: productListVC)
                    destinationVC = productListNav
                } else if itemIndex == 3 {
                    let settingsVC = UIStoryboard.settingsViewController()
                    settingsVC.fromGridIndex = 1
                    let settingsNav = UINavigationController(rootViewController: settingsVC)
                    destinationVC = settingsNav
                }
                
                if let destVC = destinationVC {
                    self.viewControllerTransitionWithSaving(false, destVC: destVC)
                }
             
            }
            
        }
    }
}
