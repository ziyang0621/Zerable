//
//  AddressViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/9/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class AddressViewController: UIViewController {
    
    var resultSearchController = UISearchController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var addressList: [CLPlacemark] = []
    
    let geocoder = CLGeocoder()
    
    let region = CLCircularRegion(center: CLLocationCoordinate2DMake(37.7577, -122.4376), radius: 1000, identifier: "region")

    override func viewDidLoad() {
        super.viewDidLoad()

        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            self.navigationItem.titleView = controller.searchBar
            return controller
        })()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        resultSearchController.searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension AddressViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        addressList.removeAll(keepCapacity: false)

        if searchController.searchBar.text.isEmpty {
            return
        }
        
        geocoder.geocodeAddressString(searchController.searchBar.text, inRegion: region, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                println(error)
            } else {
                self.addressList = placemarks as! [CLPlacemark]
                self.tableView.reloadData()
            }
        })
    }
}

extension AddressViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as? UITableViewCell
        if let cell = cell {
            
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "AddressCell")
        }
        
        let lines = ABCreateStringWithAddressDictionary(addressList[indexPath.row].addressDictionary, false)
        let addressString = lines.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: .LiteralSearch, range: nil)
        cell!.textLabel!.text = addressString

        return cell!
    }
}

extension AddressViewController: UITableViewDelegate {
    
}
