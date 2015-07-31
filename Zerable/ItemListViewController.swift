//
//  ItemListViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/26/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import RNGridMenu
import Parse

class ItemListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var assistButton: UIButton!
    @IBOutlet weak var loadingInfoView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadLabel: UILabel!
    
    var fromGridIndex = 0
    var resultSearchController = UISearchController()
    var filteredTableData = [PFObject]()
    var totalPages = 0
    let numberOfItemsPerPage = 8
    var currentPage = 1
    var productList = [PFObject]()
    let refreshControl = UIRefreshControl()
    var fetchingProducts = false
    var viewDidAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("viewDidLoad")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            self.navigationItem.titleView = controller.searchBar
            
            return controller
        })()
        
        UIView.applyCurvedShadow(assistButton.imageView!)
        
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        fetchProducts()
    }
    
    func showLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.loadingInfoView.alpha = 1
                self.loadingIndicator.alpha = 1
                self.loadLabel.text = "Loading..."
            })
        }
    }
    
    func hideLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.loadingInfoView.alpha = 0
            })
        }
    }
    
    func showAllProductsLoaded() {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingInfoView.alpha = 1
            self.loadingIndicator.alpha = 0
            self.loadLabel.text = "All item loaded"
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.loadingInfoView.alpha = 0
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if viewDidAppear {
            if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
                fetchProducts()
            }
        }
    }

    
    func handleRefresh() {
        refreshControl.beginRefreshing()
        
        productList.removeAll(keepCapacity: false)
        self.currentPage = 1
        self.totalPages = 0
        
        tableView.reloadData()
        
        fetchProducts()
    }
    
    func fetchProducts() {
        if fetchingProducts {
            return
        }
        
        if currentPage > totalPages && totalPages != 0{
            showAllProductsLoaded()
            fetchingProducts = false
            return
        }
        
        showLoading()
        fetchingProducts = true
        let countQuery = PFQuery(className: "Product")
        countQuery.countObjectsInBackgroundWithBlock {
            (counts: Int32, error: NSError?) -> Void in
            if error == nil {
                self.totalPages = Int(ceil(Double(counts) / Double(self.numberOfItemsPerPage)))
                println(self.totalPages)
                let query = PFQuery(className: "Product")
                query.limit = 8
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if let error = error {
                        self.resetUI()
                        let errorString = error.userInfo?["error"] as? String
                        println(errorString)
                    } else {
                        if let products = objects as? [PFObject] {
                            println("query count \(self.productList.count)")
                            self.productList.extend(products)
                            self.resetUI()
                            self.currentPage++
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    func resetUI() {
        self.fetchingProducts = false
        self.refreshControl.endRefreshing()
        self.hideLoading()
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
        
        viewDidAppear = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        println("viewDidLayoutSubviews")
    }
    
    @IBAction func assistButtonPressed(sender: AnyObject) {
      
        let gridMenu = RNGridMenu(images: [UIImage(named: "home")!.newImageWithColor(kThemeColor),
            UIImage(named: "shopping")!.newImageWithColor(kThemeColor),
            UIImage(named: "history")!.newImageWithColor(kThemeColor),
            UIImage(named: "settings")!.newImageWithColor(kThemeColor)])
        
        gridMenu.delegate = self
        gridMenu.showInViewController(navigationController, center: CGPoint(x: CGRectGetWidth(view.frame)/2, y: CGRectGetHeight(view.frame)/2))
    }
}

extension ItemListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell
        var product: PFObject!
        if (resultSearchController.active) {
            product = filteredTableData[indexPath.row]
        } else {
            product = productList[indexPath.row]
        }
        
        cell.itemName = product["name"] as? String
        cell.itemImageView.file = product["thumbnail"] as? PFFile
        cell.itemImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
            if error == nil {
                println("cell image loaded")
            } else {
                let errorString = error!.userInfo?["error"] as? String
                println(errorString)
            }
        })

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(productList.count)
        if (resultSearchController.active) {
            return filteredTableData.count
        }
        else {
            return productList.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
}

extension ItemListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let itemDetailVC = UIStoryboard.itemDetailViewController()
        itemDetailVC.item = productList[indexPath.row]
        itemDetailVC.headerImage = (tableView.cellForRowAtIndexPath(indexPath) as! ItemCell).itemImageView.image
        showViewController(itemDetailVC, sender: self)
    }
}

extension ItemListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredTableData.removeAll(keepCapacity: false)
        
        let query = PFQuery(className: "Product")
        query.whereKey("name", containsString: searchController.searchBar.text)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                self.resetUI()
                let errorString = error.userInfo?["error"] as? String
                println(errorString)
            } else {
                if let products = objects as? [PFObject] {
                    self.filteredTableData.extend(products)
                    self.resetUI()
                    self.currentPage++
                    self.tableView.reloadData()
                }
            }
        }
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

