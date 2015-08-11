//
//  CartViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Cart"
        
        let leftBarButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeButtonTapped")
        navigationItem.leftBarButtonItem = leftBarButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
        tableView.estimatedRowHeight = 120
    }
    
    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CartViewController: UITableViewDelegate {
    
}


extension CartViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CartItemCell", forIndexPath: indexPath) as! CartItemCell
        cell.maxQuantity = 3
        cell.miniQuantity = 0
        cell.currentQuantity = 1
        return cell
    }
}