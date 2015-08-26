//
//  OrderHistoryViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import RNGridMenu

class OrderHistoryViewController: UIViewController {

    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var assistButton: UIButton!
    
    var fromGridIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Order History"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func assistButtonPressed(sender: AnyObject) {
        
        let gridMenu = RNGridMenu(images: [UIImage(named: "home")!.newImageWithColor(kThemeColor),
            UIImage(named: "shopping")!.newImageWithColor(kThemeColor),
            UIImage(named: "history")!.newImageWithColor(kThemeColor),
            UIImage(named:"settings")!.newImageWithColor(kThemeColor)])
        
        gridMenu.delegate = self
        gridMenu.showInViewController(navigationController, center: CGPoint(x: CGRectGetWidth(view.frame)/2, y: CGRectGetHeight(view.frame)/2))
    }
}


extension OrderHistoryViewController: RNGridMenuDelegate {
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
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
