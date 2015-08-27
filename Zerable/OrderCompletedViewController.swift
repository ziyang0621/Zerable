//
//  OrderCompletedViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class OrderCompletedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Thank you"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func OKButtonTapped(sender: AnyObject) {
        let productListVC = UIStoryboard.productListViewController()
        let productListNav = UINavigationController(rootViewController: productListVC)
        presentViewController(productListNav, animated: true, completion: nil)
    }
}
