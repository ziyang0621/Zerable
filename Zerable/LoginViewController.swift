//
//  LoginViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var forgetPasswordLabel: UILabel!
    let MyKeychainWrapper = KeychainWrapper()
    var keyboardIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        contentView.addGestureRecognizer(viewTap)
        
        emailTextfield.layer.cornerRadius = CGRectGetHeight(emailTextfield.frame) / 2
        passwordTextfield.layer.cornerRadius = CGRectGetHeight(passwordTextfield.frame) / 2
        loginButton.layer.cornerRadius = CGRectGetHeight(loginButton.frame) / 2
        signupButton.layer.cornerRadius = CGRectGetHeight(signupButton.frame) / 2
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        let topInset = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame) +
            (navigationController?.navigationBar == nil ? 0 : CGRectGetHeight(navigationController!.navigationBar.frame))
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.locationInView(contentView)
      
        if CGRectContainsPoint(forgetPasswordLabel.frame, location) {
            forgetPassword()
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
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        if password == MyKeychainWrapper.myObjectForKey("v_Data") as? NSString &&
            username == NSUserDefaults.standardUserDefaults().valueForKey("username") as? NSString {
                return true
        } else {
            return false
        }
    }
    
    func login() {
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        
        if emailTextfield.text != "" && passwordTextfield.text != "" {
            if !validateEmail(emailTextfield.text) {
                let alert = UIAlertController(title: "Login Failed", message: "Invalid email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                if checkLogin(emailTextfield.text, password: passwordTextfield.text) {
                    println("can login")
                } else {
                    let alert = UIAlertController(title: "Login Failed", message: "Wrong email or password", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    presentViewController(alert, animated: true, completion: nil)
                }

            }
        } else {
            let alert = UIAlertController(title: "Missing information", message: "Please enter both email and password", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        login()
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        let signupVC = UIStoryboard.signupViewController()
        let signupNavVC = UINavigationController(rootViewController: signupVC)
        presentViewController(signupNavVC, animated: true, completion: nil)
    }
    
    func forgetPassword() {
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            emailTextfield.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
        } else {
            login()
        }
        return true
    }
}

