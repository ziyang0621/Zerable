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
    @IBOutlet weak var loadingInfoView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadLabel: UILabel!
    
    var fromGridIndex = 0
    var itemList: [String] = []
    var resultSearchController = UISearchController()
    var filteredTableData = [String]()
    var totalPages = 0
    let numberOfItemsPerPage = 8
    var currentPage = 1
    var productList = [PFObject]()
    var productThumbnailImages = [PFFile]()
    let refreshControl = UIRefreshControl()
    var fetchingProducts = false
    var viewDidAppear = false
    
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
        productThumbnailImages.removeAll(keepCapacity: false)
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
                            self.fetchProductImageFiles()
                        }
                    }
                })
            }
        }
    }
    
    func fetchProductImageFiles() {
        var imageCount = 0
        for product in productList {
            let productImageQuery = PFQuery(className: "ImageFile")
            productImageQuery.whereKey("imageType", equalTo: "thumbnailImage")
            productImageQuery.whereKey("product", equalTo: product)
            productImageQuery.limit = 1
            productImageQuery.findObjectsInBackgroundWithBlock({
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let imageFile = objects?.first as? PFObject {
                        self.productThumbnailImages.append(imageFile["imageFile"] as! PFFile)
                        imageCount++
                        if imageCount == self.productList.count {
                            self.resetUI()
                            self.currentPage++
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    self.resetUI()
                    let errorString = error!.userInfo?["error"] as? String
                    println(errorString)
                }
            })

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
            UIImage(named:"settings")!.newImageWithColor(kThemeColor)])
        
        gridMenu.delegate = self
        gridMenu.showInViewController(navigationController, center: CGPoint(x: CGRectGetWidth(view.frame)/2, y: CGRectGetHeight(view.frame)/2))
    }
}

extension ItemListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell
        let product = productList[indexPath.row]
        if (resultSearchController.active) {
            cell.itemImage = UIImage(named: filteredTableData[indexPath.row])
            cell.itemName = filteredTableData[indexPath.row]

        } else {
            cell.itemName = product["name"] as? String
            cell.itemImageView.file = productThumbnailImages[indexPath.row]
            cell.itemImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    println("cell image loaded")
                } else {
                    let errorString = error!.userInfo?["error"] as? String
                    println(errorString)
                }
            })
        }
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

