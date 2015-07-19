//
//  WelcomeViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/29/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var loginButton: ZerableRoundButton!
    @IBOutlet weak var signupButton: ZerableRoundButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if PFUser.currentUser() != nil {
            let itemListVC = UIStoryboard.itemListViewController()
            itemListVC.fromGridIndex = -1
            let itemListNav = UINavigationController(rootViewController: itemListVC)
            presentViewController(itemListNav, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIColor.imageWithColor(UIColor.clearColor()), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIColor.imageWithColor(UIColor.clearColor())

    }
    
    @IBAction func login(sender: AnyObject) {
        let loginVC = UIStoryboard.loginlViewController()
        showViewController(loginVC, sender: self)
    }

    @IBAction func signup(sender: AnyObject) {
        let signupVC = UIStoryboard.signupViewController()
        showViewController(signupVC, sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}
