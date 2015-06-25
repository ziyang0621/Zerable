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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgetPasswordLabel: UILabel!
    let MyKeychainWrapper = KeychainWrapper()
    var keyboardIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        contentView.addGestureRecognizer(viewTap)
        
        emailTextField.layer.cornerRadius = CGRectGetHeight(emailTextField.frame) / 2
        passwordTextField.layer.cornerRadius = CGRectGetHeight(passwordTextField.frame) / 2
        loginButton.layer.cornerRadius = CGRectGetHeight(loginButton.frame) / 2
        signupButton.layer.cornerRadius = CGRectGetHeight(signupButton.frame) / 2
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
    
    func checkLogin(email: String, password: String) -> Bool {
        println(MyKeychainWrapper.myObjectForKey("v_data") as? NSString)
        if password == MyKeychainWrapper.myObjectForKey("v_Data") as? NSString &&
            email == NSUserDefaults.standardUserDefaults().valueForKey("email") as? NSString {
                return true
        } else {
            return false
        }
    }
    
    func login() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            if !validateEmail(emailTextField.text) {
                let alert = UIAlertController(title: "Login Failed", message: "Invalid email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                if checkLogin(emailTextField.text, password: passwordTextField.text) {
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
            (TextField: UITextField!) -> Void in
            TextField.placeholder = "email address"
            TextField.keyboardType = .EmailAddress
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            let TextField = alert.textFields?.first as! UITextField
            if TextField.text == "" {
                let alert = UIAlertController(title: "Pasword Reset Failed", message: "You must provide an email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                if !validateEmail(TextField.text) {
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
    func TextFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            login()
        }
        return true
    }
}

