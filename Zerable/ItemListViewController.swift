//
//  ItemListViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/26/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ItemListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var assistButton: UIButton!
    
    var fromGridIndex = 0
    
    let refreshControl = UIRefreshControl()
    
    var itemList: [String] = []
    
    var resultSearchController = UISearchController()
    
    var filteredTableData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("viewDidLoad")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.registerNib(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        
        itemList = ["frozen-beef", "frozen-red-meat", "frozen-pork", "frozen-shrimp", "frozen-chicken"]
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            self.navigationItem.titleView = controller.searchBar
            
            return controller
        })()
        
        UIView.applyCurvedShadow(assistButton.imageView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        println("viewDidAppear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        println("viewDidLayoutSubviews")
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

extension ItemListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell
        if (resultSearchController.active) {
            cell.itemImage = UIImage(named: filteredTableData[indexPath.row])
            cell.itemName = filteredTableData[indexPath.row]

        } else {
            cell.itemImage = UIImage(named: itemList[indexPath.row])
            cell.itemName = itemList[indexPath.row]

        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.active) {
            return filteredTableData.count
        }
        else {
            return itemList.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
}

extension ItemListViewController: UITableViewDelegate {
    
}

extension ItemListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredTableData.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text)
        let array = (itemList as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [String]
        
        tableView.reloadData()
    }
}

extension ItemListViewController: RNGridMenuDelegate {
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
        delay(seconds: 0.3) { () -> () in
            if itemIndex == 0 {
                return
            }
            if itemIndex == self.fromGridIndex {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                if itemIndex == 3 {
                    let settingsVC = UIStoryboard.settingsViewController()
                    settingsVC.fromGridIndex = 0
                    let settingsNav = UINavigationController(rootViewController: settingsVC)
                    self.presentViewController(settingsNav, animated: true, completion: nil)
                }
            }

        }
        
    }
 }

