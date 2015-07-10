//
//  SettingsViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/8/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

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
                    let itemListVC = UIStoryboard.itemListViewController()
                    itemListVC.fromGridIndex == 3
                    let itemListNav = UINavigationController(rootViewController: itemListVC)
                    self.presentViewController(itemListNav, animated: true, completion: nil)
                }
            }

        }
    }
}