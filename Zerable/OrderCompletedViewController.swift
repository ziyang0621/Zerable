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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
