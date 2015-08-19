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
import ZTDropDownTextField
import Parse
import KVNProgress

class AddressViewController: UIViewController {

    @IBOutlet weak var saveButton: ZerableRoundButton!
    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fullAddressTextField: ZTDropDownTextField!
    @IBOutlet weak var optionalAddressTextField: UITextField!
    @IBOutlet weak var addressSummaryTextView: UITextView!
    let geocoder = CLGeocoder()
    let region = CLCircularRegion(center: CLLocationCoordinate2DMake(37.7577, -122.4376), radius: 1000, identifier: "region")
    var placemarkList: [CLPlacemark] = []
    var selectedPlacemark: CLPlacemark?
    var loadedAddressSummary = ""
    var toCheckout = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullAddressTextField.delegate = self
        fullAddressTextField.dataSourceDelegate = self
        fullAddressTextField.addTarget(self, action: "fullAddressTextDidChanged:", forControlEvents:.EditingChanged)
        
        optionalAddressTextField.delegate = self
        optionalAddressTextField.addTarget(self, action: "optionalAddressTextDidChanged:", forControlEvents:.EditingChanged)

        addressSummaryTextView.layer.cornerRadius = 5
        
        
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "UserAddress")
            query.whereKey("user", equalTo: currentUser)
            query.orderByDescending("createdAt")
            query.getFirstObjectInBackgroundWithBlock({
                (address: PFObject?, error:NSError?) -> Void in
                self.fullAddressTextField.text = address!["fullAddress"] as! String
                self.optionalAddressTextField.text = address!["optionalAddress"] as! String
                self.addressSummaryTextView.text = address!["addressSummary"] as! String
                self.loadedAddressSummary = self.addressSummaryTextView.text
                self.selectedPlacemark =  NSKeyedUnarchiver.unarchiveObjectWithData(address!["placeMark"] as! NSData) as? CLPlacemark
                self.changeSaveButtonState()
            })
        }
        
        if toCheckout {
            saveButton.setTitle("Next", forState: .Normal)
        } else {
            scrollView.topInset = 64
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if loadedAddressSummary == addressSummaryTextView.text {
            if self.toCheckout {
                let paymentInfoVC = UIStoryboard.paymentInfoViewController()
                paymentInfoVC.toCheckout = true
                self.showViewController(paymentInfoVC, sender: self)
            }

            return
        }
        if checkAddress() {
            if let currentUser = PFUser.currentUser() {
                let userAddress = PFObject(className: "UserAddress")
                userAddress["fullAddress"] = fullAddressTextField.text
                userAddress["optionalAddress"] = optionalAddressTextField.text
                userAddress["addressSummary"] = addressSummaryTextView.text
                userAddress["placeMark"] = NSKeyedArchiver.archivedDataWithRootObject(selectedPlacemark!)
                userAddress["user"] = currentUser
                
                KVNProgress.showWithStatus("Saving...")
                userAddress.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError?) -> Void in
                    if self.toCheckout {
                        KVNProgress.dismiss()
                    } else {
                        KVNProgress.showSuccess()
                    }
                    if let error = error {
                        let errorString = error.userInfo?["error"] as? String
                        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.loadedAddressSummary = self.addressSummaryTextView.text
                        
                        if self.toCheckout {
                            let paymentInfoVC = UIStoryboard.paymentInfoViewController()
                            paymentInfoVC.toCheckout = true
                            self.showViewController(paymentInfoVC, sender: self)
                        }
                    }
                })
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Address is not completed", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func fullAddressTextDidChanged(textField: UITextField) {
        changeSaveButtonState()

        if textField.text.isEmpty {
            placemarkList.removeAll(keepCapacity: false)
            if let dropDownTableView = fullAddressTextField.dropDownTableView {
                dropDownTableView.reloadData()
            }
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
        changeSaveButtonState()
        addressSummaryTextView.text = formattedAddressWithOptionalLine()
    }
    
    func formateedFullAddress(placemark: CLPlacemark) -> String {
        let lines = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
        let addressString = lines.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: .LiteralSearch, range: nil)
        return addressString
    }
    
    func checkAddress() -> Bool {
        if let selectedPlacemark = selectedPlacemark {
            if selectedPlacemark.subThoroughfare == nil || selectedPlacemark.thoroughfare == nil ||
            selectedPlacemark.locality == nil || selectedPlacemark.administrativeArea == nil ||
                selectedPlacemark.postalCode == nil || selectedPlacemark.country == nil {
                    return false
            }
            return true
        }
        return false
    }
    
    func formattedAddressWithOptionalLine() -> String {
        if let selectedPlacemark = selectedPlacemark {
            var addressSummaryString = ""
            if let subThoroughfare = selectedPlacemark.subThoroughfare {
                addressSummaryString += subThoroughfare + " "
            }
            if let thoroughfare = selectedPlacemark.thoroughfare {
                addressSummaryString += thoroughfare + "\n"
            } else {
                if !addressSummaryString.isEmpty {
                    addressSummaryString += "\n"
                }
            }
            addressSummaryString += optionalAddressTextField.text.isEmpty ? "" : optionalAddressTextField.text + "\n"
            if let locality = selectedPlacemark.locality {
                addressSummaryString += locality + " "
            }
            if let administrativeArea = selectedPlacemark.administrativeArea {
                addressSummaryString += administrativeArea + " "
            }
            if let postalCode = selectedPlacemark.postalCode {
                addressSummaryString += postalCode + "\n"
            } else {
                if !addressSummaryString.isEmpty {
                    addressSummaryString += "\n"
                }
            }
            if let country = selectedPlacemark.country {
                addressSummaryString += country
            }
            return addressSummaryString
        }
        return ""
    }
}

extension AddressViewController: ZTDropDownTextFieldDataSourceDelegate {
    func dropDownTextField(dropDownTextField: ZTDropDownTextField, numberOfRowsInSection section: Int) -> Int {
        return placemarkList.count
    }
    
    func dropDownTextField(dropDownTextField: ZTDropDownTextField, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = dropDownTextField.dropDownTableView.dequeueReusableCellWithIdentifier("addressCell") as? UITableViewCell
        if let cell = cell {
            
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "addressCell")
        }
        
        cell!.textLabel!.text = formateedFullAddress(placemarkList[indexPath.row])
        cell!.textLabel?.numberOfLines = 0
        return cell!
    }
    
    func dropDownTextField(dropDownTextField: ZTDropDownTextField, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPlacemark = placemarkList[indexPath.row]
        println(selectedPlacemark?.subThoroughfare)
        println(selectedPlacemark?.thoroughfare)
        println(selectedPlacemark?.locality)
        println(selectedPlacemark?.administrativeArea)
        println(selectedPlacemark?.postalCode)
        println(selectedPlacemark?.country)
        fullAddressTextField.text = formateedFullAddress(placemarkList[indexPath.row])
        addressSummaryTextView.text = ABCreateStringWithAddressDictionary(placemarkList[indexPath.row].addressDictionary, false)
        addressSummaryTextView.text = formattedAddressWithOptionalLine()
    }
    
    func changeSaveButtonState() {
        saveButton.enabled = !fullAddressTextField.text.isEmpty ? true : false
        saveButton.backgroundColor = !fullAddressTextField.text.isEmpty ? kThemeColor : UIColor.lightGrayColor()
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
