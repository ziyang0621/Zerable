//
//  ViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/22/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        usernameTextfield.layer.cornerRadius = CGRectGetHeight(usernameTextfield.frame) / 2
        passwordTextfield.layer.cornerRadius = CGRectGetHeight(passwordTextfield.frame) / 2
        loginButton.layer.cornerRadius = CGRectGetHeight(loginButton.frame) / 2
        signupButton.layer.cornerRadius = CGRectGetHeight(signupButton.frame) / 2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func dismissKeyboard() {
        for view in contentView.subviews {
            if view.isKindOfClass(UITextField) {
                (view as! UITextField).resignFirstResponder()
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) -
            (navigationController?.toolbar == nil ? 0 : CGRectGetHeight(navigationController!.toolbar.frame)) + 20) * (show ? 1 : -1)
        
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func forgetPasswordButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Reset Password", message: "Please enter the email address for your account", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
                textField.placeholder = "email address"
                textField.keyboardType = .EmailAddress
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            let textField = alert.textFields?.first as! UITextField
            if textField.text == "" {
                let alert = UIAlertController(title: "Pasword Reset Failed", message: "You must provide an email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                if !self.validateEmail(textField.text) {
                    let alert = UIAlertController(title: "Pasword Reset Failed", message: "Invalid email address", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    // do something
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

