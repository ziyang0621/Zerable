//
//  SettingsViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/8/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import RNGridMenu
import Parse

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var assistButton: UIButton!
    
    var fromGridIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerNib(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        
        UIView.applyCurvedShadow(assistButton.imageView!)
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

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as! SettingsCell
        cell.indexPath = indexPath
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let profileVC = UIStoryboard.profileViewController()
//            let profileNav = UINavigationController(rootViewController: profileVC)
         //   presentViewController(profileNav, animated: true, completion: nil)
            navigationController?.showViewController(profileVC, sender: self)
        } else if indexPath.section == 3 {
            let alert = UIAlertController(title: "Log out", message: "Are you sure to log out?", preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Yes, log out", style: .Destructive, handler: { (action: UIAlertAction!) -> Void in
                PFUser.logOut()
                let welcomeVC = UIStoryboard.welcomeViewController()
                let welcomeNav = UINavigationController(rootViewController: welcomeVC)
                self.presentViewController(welcomeNav, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: RNGridMenuDelegate {
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
        delay(seconds: 0.3) { () -> () in
            if itemIndex == 3 {
                return
            }
            if itemIndex == self.fromGridIndex {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                if itemIndex == 0 {
                    let productListVC = UIStoryboard.productListViewController()
                    productListVC.fromGridIndex == 3
                    let productListNav = UINavigationController(rootViewController: productListVC)
                    self.presentViewController(productListNav, animated: true, completion: nil)
                }
            }

        }
    }
}
