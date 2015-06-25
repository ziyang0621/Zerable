//
//  SignupViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstnameTextfield: UITextField!
    @IBOutlet weak var lastnameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var termLabel: UILabel!
    let MyKeychainWrapper = KeychainWrapper()
    var keyboardIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        contentView.addGestureRecognizer(viewTap)

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSignup")
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(title: "Sign up", style: .Plain, target: self, action: "startSignup")
        navigationItem.rightBarButtonItem = rightBarButton
        
//        let topInset = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame) +
//            (navigationController?.navigationBar == nil ? 0 : CGRectGetHeight(navigationController!.navigationBar.frame))
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        firstnameTextfield.delegate = self
        lastnameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.locationInView(contentView)
        
        if CGRectContainsPoint(termLabel.frame, location) {
            return
        }
        
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        for view in contentView.subviews {
            if view.isKindOfClass(UITextField) {
                (view as! UITextField).resignFirstResponder()
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardIsShown {
            adjustInsetForKeyboardShow(true, notification: notification)
        }
        keyboardIsShown = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardIsShown {
            adjustInsetForKeyboardShow(false, notification: notification)
        }
        keyboardIsShown = false
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) -
            (navigationController?.toolbar == nil ? 0 : CGRectGetHeight(navigationController!.toolbar.frame)) + 20) * (show ? 1 : -1)
        
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
   
    func signup() {
        if firstnameTextfield.text != "" && lastnameTextfield.text != "" &&
            emailTextfield.text != "" && passwordTextfield.text != "" {
            if !validateEmail(emailTextfield.text) {
                let alert = UIAlertController(title: "Login Failed", message: "Invalid email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                NSUserDefaults.standardUserDefaults().setValue(emailTextfield.text, forKey: "email")
                
                MyKeychainWrapper.mySetObject(passwordTextfield.text, forKey: kSecValueData)
                MyKeychainWrapper.writeToKeychain()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
                NSUserDefaults.standardUserDefaults().synchronize()
                
            }
        } else {
            let alert = UIAlertController(title: "Missing information", message: "Please enter information for all fields", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func startSignup() {
        signup()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelSignup() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            firstnameTextfield.resignFirstResponder()
            lastnameTextfield.becomeFirstResponder()
        } else if textField.tag == 1 {
            lastnameTextfield.resignFirstResponder()
            emailTextfield.becomeFirstResponder()
        } else if textField.tag == 2 {
            emailTextfield.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
        } else {
            signup()
        }
        return true
    }
}

