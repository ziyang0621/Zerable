//
//  BasicInfoViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import REFormattedNumberField
import Parse
import KVNProgress

class BasicInfoViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneTextField: REFormattedNumberField!
    @IBOutlet weak var saveButton: ZerableRoundButton!
    var toCheckout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.format = "(XXX) XXX-XXXX";
        
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        phoneTextField.delegate = self
        
        inputViewStyle(firstnameTextField)
        inputViewStyle(lastnameTextField)
        inputViewStyle(phoneTextField)
        
        PFUser.currentUser()?.fetchIfNeededInBackgroundWithBlock({
            (object: PFObject?, error:NSError?) -> Void in
            let user = object as! PFUser
            self.firstnameTextField.text = user["firstName"] as! String
            self.lastnameTextField.text = user["lastName"] as! String
            self.phoneTextField.text = user["phoneNumber"] as! String
            self.changeSaveButtonState()
        })
        
        if toCheckout {
            saveButton.setTitle("Next", forState: .Normal)
        } else {
            scrollView.topInset = 64
        }
        
        firstnameTextField.addTarget(self, action: "textDidChanged:", forControlEvents:.EditingChanged)
        lastnameTextField.addTarget(self, action: "textDidChanged:", forControlEvents:.EditingChanged)
        phoneTextField.addTarget(self, action: "textDidChanged:", forControlEvents:.EditingChanged)
    }
    
    func changeSaveButtonState() {
        saveButton.enabled = !firstnameTextField.text.isEmpty && !lastnameTextField.text.isEmpty && count(phoneTextField.unformattedText) == 10 ? true : false
        saveButton.backgroundColor = !firstnameTextField.text.isEmpty && !lastnameTextField.text.isEmpty && count(phoneTextField.unformattedText) == 10 ? kThemeColor : UIColor.lightGrayColor()
    }
    
    func textDidChanged(textField: UITextField) {
        changeSaveButtonState()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if let currentUser = PFUser.currentUser() {
            currentUser["firstName"] = firstnameTextField.text
            currentUser["lastName"] = lastnameTextField.text
            currentUser["phoneNumber"] = phoneTextField.text
            
            KVNProgress.showWithStatus("Saving...")
            currentUser.saveInBackgroundWithBlock({
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
                    if self.toCheckout {
                        let addressVC = UIStoryboard.addressViewController()
                        addressVC.toCheckout = true
                        self.showViewController(addressVC, sender: self)
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension BasicInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            firstnameTextField.resignFirstResponder()
            lastnameTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            lastnameTextField.resignFirstResponder()
            phoneTextField.becomeFirstResponder()
        }
        return true
    }
    
}
