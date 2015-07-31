//
//  LoginViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import KVNProgress
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgetPasswordLabel: UILabel!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        forgetPasswordLabel.addGestureRecognizer(viewTap)
        
        emailTextField.layer.cornerRadius = CGRectGetHeight(emailTextField.frame) / 2
        passwordTextField.layer.cornerRadius = CGRectGetHeight(passwordTextField.frame) / 2
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let rightBarButton = UIBarButtonItem(title: "Log In", style: .Plain, target: self, action: "login")
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIColor.imageWithColor(kThemeColor), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIColor.imageWithColor(kThemeColor)
    }
    
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        forgetPassword()
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
                KVNProgress.showWithStatus("Loggin in...")
                PFUser.logInWithUsernameInBackground(emailTextField.text, password: passwordTextField.text, block: {
                    (user: PFUser?, error:NSError?) -> Void in
                    KVNProgress.dismiss()
                    if user != nil {
                        let itemListVC = UIStoryboard.itemListViewController()
                        itemListVC.fromGridIndex = -1
                        let itemListNav = UINavigationController(rootViewController: itemListVC)
                        self.presentViewController(itemListNav, animated: true, completion: nil)
                    } else {
                        if let error = error {
                            let errorString = error.userInfo?["error"] as? String
                            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        } else {
            let alert = UIAlertController(title: "Missing information", message: "Please enter both email and password", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
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
                if !validateEmail(textField.text) {
                    let alert = UIAlertController(title: "Pasword Reset Failed", message: "Invalid email address", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    PFUser.requestPasswordResetForEmailInBackground(textField.text, block: { (succeeded: Bool, error:NSError?) -> Void in
                        if let error = error {
                            let errorString = error.userInfo?["error"] as? String
                            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Sent", message: "Password reset email sent", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            login()
        }
        return true
    }
    
  
}

