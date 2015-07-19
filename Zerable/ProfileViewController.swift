//
//  ProfileViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tabBar: UITabBar!
    
    var basicInfoVC: BasicInfoViewController!
    var addressInfoVC: AddressViewController!
    var paymentInfoVC: PaymentInfoViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Profile"
        tabBar.delegate = self
        
//        let leftBarButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "close")
//        navigationItem.leftBarButtonItem = leftBarButton
        
        if basicInfoVC == nil {
            basicInfoVC = UIStoryboard.basicViewController()
        }
        view.insertSubview(basicInfoVC.view, belowSubview: tabBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


extension ProfileViewController: UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        switch (item.tag) {
        case 0:
            if basicInfoVC == nil {
                basicInfoVC = UIStoryboard.basicViewController()
            }
            view.insertSubview(basicInfoVC.view, belowSubview: tabBar)
        case 1:
            if addressInfoVC == nil {
                addressInfoVC = UIStoryboard.addressViewController()
            }
            view.insertSubview(addressInfoVC.view, belowSubview: tabBar)
        case 2:
            if paymentInfoVC == nil {
                paymentInfoVC = UIStoryboard.paymentInfoViewController()
            }
            view.insertSubview(paymentInfoVC.view, belowSubview: tabBar)
        default:
            println("default")
        }
    }
}