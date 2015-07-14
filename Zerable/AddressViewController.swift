//
//  AddressViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class AddressViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fullAddressTextField: ZerableDropDownTextField!
    @IBOutlet weak var optionalAddressTextField: UITextField!
    @IBOutlet weak var finalAddressTextView: UITextView!
    let geocoder = CLGeocoder()
    let region = CLCircularRegion(center: CLLocationCoordinate2DMake(37.7577, -122.4376), radius: 1000, identifier: "region")
    var placemarkList: [CLPlacemark] = []
    var selectedPlacemark: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.topInset = 64
        
        fullAddressTextField.delegate = self
        fullAddressTextField.dataSourceDelegate = self
        fullAddressTextField.addTarget(self, action: "fullAddressTextDidChanged:", forControlEvents:.EditingChanged)
        
        optionalAddressTextField.delegate = self
        optionalAddressTextField.addTarget(self, action: "optionalAddressTextDidChanged:", forControlEvents:.EditingChanged)

        finalAddressTextView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fullAddressTextDidChanged(textField: UITextField) {
        
        if textField.text.isEmpty {
            placemarkList.removeAll(keepCapacity: false)
            fullAddressTextField.dropDownTableView.reloadData()
            return
        }
        
        geocoder.geocodeAddressString(textField.text, inRegion: region, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                println(error)
            } else {
                self.placemarkList.removeAll(keepCapacity: false)
                self.placemarkList = placemarks as! [CLPlacemark]
                self.fullAddressTextField.dropDownTableView.reloadData()
            }
        })
    }
    
    func optionalAddressTextDidChanged(textField: UITextField) {
        finalAddressTextView.text = formattedAddressWithOptionalLine()
    }
    
    func formateedFullAddress(placemark: CLPlacemark) -> String {
        let lines = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
        let addressString = lines.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: .LiteralSearch, range: nil)
        return addressString
    }
    
    func formattedAddressWithOptionalLine() -> String {
        if let selectedPlacemark = selectedPlacemark {
            var addressSummaryString = ""
            addressSummaryString += selectedPlacemark.subThoroughfare + " "
            addressSummaryString += selectedPlacemark.thoroughfare + "\n"
            addressSummaryString += optionalAddressTextField.text.isEmpty ? "" : optionalAddressTextField.text + "\n"
            addressSummaryString += selectedPlacemark.locality + " "
            addressSummaryString += selectedPlacemark.administrativeArea + " "
            addressSummaryString += selectedPlacemark.postalCode + "\n"
            addressSummaryString += selectedPlacemark.country
            return addressSummaryString
        }
        return ""
    }
}

extension AddressViewController: ZerableDropDownTextFieldDataSourceDelegate {
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, numberOfRowsInSection section: Int) -> Int {
        return placemarkList.count
    }
    
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = dropDownTextField.dropDownTableView.dequeueReusableCellWithIdentifier("addressCell") as? UITableViewCell
        if let cell = cell {
            
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "addressCell")
        }
        
        cell!.textLabel!.text = formateedFullAddress(placemarkList[indexPath.row])
        cell!.textLabel?.numberOfLines = 0
        return cell!
    }
    
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPlacemark = placemarkList[indexPath.row]
        fullAddressTextField.text = formateedFullAddress(placemarkList[indexPath.row])
        finalAddressTextView.text = ABCreateStringWithAddressDictionary(placemarkList[indexPath.row].addressDictionary, false)
        finalAddressTextView.text = formattedAddressWithOptionalLine()
    }
}

extension AddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            fullAddressTextField.resignFirstResponder()
            optionalAddressTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            optionalAddressTextField.resignFirstResponder()
        }
        return true
    }
}
