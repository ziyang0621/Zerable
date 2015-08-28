//
//  OrderHistoryViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import RNGridMenu
import Parse
import KVNProgress

class OrderHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var fromGridIndex = 0
    var orderHistoryList = [Order: [CartItem]]()
    var orderList = [Order]()
    let formatter: NSDateFormatter = NSDateFormatter()
    let menuControl = MenuControl()
    var gridMenu: RNGridMenu!
    var gridMenuIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuControl.tapHandler = {
            if self.gridMenuIsShown {
                self.hideGridMenu()
            } else {
                self.showGridMenu()
            }
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuControl)

        navigationItem.title = "Order History"
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "OrderedItemCell", bundle: nil), forCellReuseIdentifier: "OrderedItemCell")
        tableView.registerNib(UINib(nibName: "TotalCell", bundle: nil), forCellReuseIdentifier: "TotalCell")
        tableView.registerNib(UINib(nibName: "OrderStatusCell", bundle: nil), forCellReuseIdentifier: "OrderStatusCell")
        
        formatter.dateFormat = "dd-MM-yyyy h:mm a"
        formatter.timeZone = NSTimeZone.localTimeZone()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadOrders()
    }
    
    func loadOrders() {
        KVNProgress.showWithStatus("Loading...", onView: navigationController?.view)

        PFQuery.retrieveOrderHistory(PFUser.currentUser()!, completion: { (orderHistoryList, error) -> () in
            KVNProgress.dismiss()
            if let error = error {
                let errorString = error.userInfo?["error"] as? String
                let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                println("retrieved")
                if let orderHistoryList = orderHistoryList {
                    self.orderHistoryList = orderHistoryList
                    self.orderList = [Order](orderHistoryList.keys)
                    self.orderList.sort({ $0.createdAt!.compare($1.createdAt!) == .OrderedDescending })
                    self.tableView.reloadData()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showGridMenu() {
        gridMenuIsShown = true
        gridMenu = RNGridMenu(images: [UIImage(named: "home")!.newImageWithColor(kThemeColor),
            UIImage(named: "shopping")!.newImageWithColor(kThemeColor),
            UIImage(named: "history")!.newImageWithColor(kThemeColor),
            UIImage(named: "settings")!.newImageWithColor(kThemeColor)])
        
        gridMenu.delegate = self
        gridMenu.showInViewController(self, center: CGPoint(x: CGRectGetWidth(view.frame)/2, y: CGRectGetHeight(view.frame)/2))
    }
    
    func hideGridMenu() {
        if gridMenu != nil {
            gridMenuIsShown = false
            gridMenu.dismissAnimated(true)
        }
    }
    
    func animateMenuButton(#close: Bool) {
        if let button = navigationItem.leftBarButtonItem?.customView as? MenuControl {
            if close {
                gridMenuIsShown = false
                button.menuAnimation()
            } else {
                gridMenuIsShown = true
                button.closeAnimation()
            }
        }
    }

}

extension OrderHistoryViewController: UITableViewDelegate {
    
}

extension OrderHistoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formatter.stringFromDate(orderList[section].createdAt!)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return orderHistoryList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let order = orderList[section]
        return orderHistoryList[order]!.count + 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let order = orderList[indexPath.section]
        
        if indexPath.row < orderHistoryList[order]!.count {
            let cartItemList = orderHistoryList[order]!
            let cell = tableView.dequeueReusableCellWithIdentifier("OrderedItemCell", forIndexPath: indexPath) as! OrderedItemCell
            cell.orderItemNameLabel.text = cartItemList[indexPath.row].product.name
            cell.orderItemQuantityLabel.text = "x \(cartItemList[indexPath.row].quantity)"
            
            return cell
        }
        if indexPath.row < orderHistoryList[order]!.count + 1{
             let cell = tableView.dequeueReusableCellWithIdentifier("TotalCell", forIndexPath: indexPath) as! TotalCell
            cell.totalLabel.text = formattedCurrencyString(order.total)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderStatusCell", forIndexPath: indexPath) as! OrderStatusCell
        cell.orderStatusLabel.text = order.status
        return cell
    }
}

extension OrderHistoryViewController: RNGridMenuDelegate {
    func gridMenuWillDismiss(gridMenu: RNGridMenu!) {
        animateMenuButton(close: true)
    }
    
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
        animateMenuButton(close: true)
        delay(seconds: 0.3) { () -> () in
            if itemIndex == 2 {
                return
            }
            if itemIndex == self.fromGridIndex {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                if itemIndex == 0 {
                    let productListVC = UIStoryboard.productListViewController()
                    productListVC.fromGridIndex == 2
                    let productListNav = UINavigationController(rootViewController: productListVC)
                    self.presentViewController(productListNav, animated: true, completion: nil)
                } else if itemIndex == 1 {
                    let cartVC = UIStoryboard.cartViewController()
                    cartVC.fromGridIndex = 2
                    let cartNav = UINavigationController(rootViewController: cartVC)
                    self.presentViewController(cartNav, animated: true, completion: nil)
                } else if itemIndex == 3 {
                    let settingsVC = UIStoryboard.settingsViewController()
                    settingsVC.fromGridIndex = 2
                    let settingsNav = UINavigationController(rootViewController: settingsVC)
                    self.presentViewController(settingsNav, animated: true, completion: nil)
                }
                
            }
            
        }
    }
}
