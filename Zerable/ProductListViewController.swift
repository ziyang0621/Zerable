//
//  ProductListViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/11/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import RNGridMenu
import Parse

class ProductListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingInfoView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadLabel: UILabel!
    
    var fromGridIndex = 0
    var resultSearchController = UISearchController()
    var filteredTableData = [Product]()
    var totalPages = 0
    let numberOfproductsPerPage = 8
    var currentPage = 1
    var productList = [Product]()
    let refreshControl = UIRefreshControl()
    var fetchingProducts = false
    var viewDidAppear = false
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
            self.loadLabel.text = "All product loaded"
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
        countQuery.whereKey("stock", greaterThan: 0)
        countQuery.countObjectsInBackgroundWithBlock {
            (counts: Int32, error: NSError?) -> Void in
            if error == nil {
                self.totalPages = Int(ceil(Double(counts) / Double(self.numberOfproductsPerPage)))
                let query = PFQuery(className: "Product")
                query.whereKey("stock", greaterThan: 0)
                query.limit = 8
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if let error = error {
                        self.resetUI()
                        let errorString = error.userInfo?["error"] as? String
                        println(errorString)
                    } else {
                        if let products = objects as? [Product] {
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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppear = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

extension ProductListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell
        var product: Product!
        if (resultSearchController.active) {
            product = filteredTableData[indexPath.row]
        } else {
            product = productList[indexPath.row]
        }
        
        cell.itemName = product.name
        cell.itemImageView.file = product.thumbnail
        cell.itemImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
            if error == nil {
            //    println("cell image loaded")
            } else {
                let errorString = error!.userInfo?["error"] as? String
                println(errorString)
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

extension ProductListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let productDetailVC = UIStoryboard.productDetailViewController()
        productDetailVC.product = productList[indexPath.row]
        productDetailVC.headerImage = (tableView.cellForRowAtIndexPath(indexPath) as! ItemCell).itemImageView.image
        showViewController(productDetailVC, sender: self)
    }
}

extension ProductListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredTableData.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        
        if count(searchController.searchBar.text) > 0 {
            let query = PFQuery(className: "Product")
            query.whereKey("name", containsString: searchController.searchBar.text)
            query.whereKey("stock", greaterThan: 0)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if let error = error {
                    self.resetUI()
                    let errorString = error.userInfo?["error"] as? String
                    println(errorString)
                } else {
                    if let products = objects as? [Product] {
                        self.filteredTableData.extend(products)
                        self.resetUI()
                        self.currentPage++
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension ProductListViewController: RNGridMenuDelegate {
    func gridMenuWillDismiss(gridMenu: RNGridMenu!) {
        animateMenuButton(close: true)
    }
    
    func gridMenu(gridMenu: RNGridMenu!, willDismissWithSelectedItem item: RNGridMenuItem!, atIndex itemIndex: Int) {
        animateMenuButton(close: true)
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
                } else if itemIndex == 1 {
                    let cartVC = UIStoryboard.cartViewController()
                    cartVC.fromGridIndex = 0
                    let cartNav = UINavigationController(rootViewController: cartVC)
                    self.presentViewController(cartNav, animated: true, completion: nil)
                } else if itemIndex == 2 {
                    let orderHistoryVC = UIStoryboard.orderHistoryViewController()
                    orderHistoryVC.fromGridIndex = 0
                    let orderHitoryNav = UINavigationController(rootViewController: orderHistoryVC)
                    self.presentViewController(orderHitoryNav, animated: true, completion: nil)
                }
            }
            
        }
        
    }
}

