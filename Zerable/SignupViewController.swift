//
//  SignupViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import REFormattedNumberField
import Parse
import KVNProgress

class SignupViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: REFormattedNumberField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        termLabel.addGestureRecognizer(viewTap)
        
        let rightBarButton = UIBarButtonItem(title: "Sign up", style: .Plain, target: self, action: "startSignup")
        navigationItem.rightBarButtonItem = rightBarButton
        
        phoneTextField.format = "(XXX) XXX-XXXX";
        
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        
        inputViewStyle(firstnameTextField)
        inputViewStyle(lastnameTextField)
        inputViewStyle(emailTextField)
        inputViewStyle(phoneTextField)
        inputViewStyle(passwordTextField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIColor.imageWithColor(kThemeColor), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIColor.imageWithColor(kThemeColor)
    }

    
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        let termVC = UIStoryboard.termAndPolicyViewController()
        let termNavVC = UINavigationController(rootViewController: termVC)
        presentViewController(termNavVC, animated: true, completion: nil)
    }
    
    func signup() {
        if firstnameTextField.text != "" && lastnameTextField.text != "" &&
            emailTextField.text != "" && phoneTextField.unformattedText != "" && passwordTextField.text != "" {
            if !validateEmail(emailTextField.text) {
                let alert = UIAlertController(title: "Setup Failed", message: "Invalid email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            } else if count(phoneTextField.unformattedText) < 10 {
                let alert = UIAlertController(title: "Setup Failed", message: "Invalid phone number", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }else {
                let user = PFUser()
                user.username = emailTextField.text
                user.email = emailTextField.text
                user.password = passwordTextField.text
                user["firstName"] = firstnameTextField.text
                user["lastName"] = lastnameTextField.text
                user["phoneNumber"] = phoneTextField.text
                
                KVNProgress.showWithStatus("Signing up...")
                user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    KVNProgress.dismiss()
                    if let error = error {
                        let errorString = error.userInfo?["error"] as? String
                        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let productListVC = UIStoryboard.productListViewController()
                        productListVC.fromGridIndex = -1
                        let productListNav = UINavigationController(rootViewController: productListVC)
                        self.presentViewController(productListNav, animated: true, completion: nil)
                    }
                })
            }
        } else {
            let alert = UIAlertController(title: "Missing information", message: "Please enter information for all fields", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func startSignup() {
        signup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            firstnameTextField.resignFirstResponder()
            lastnameTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            lastnameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField.tag == 2 {
            emailTextField.resignFirstResponder()
        } else if textField.tag == 3 {
            phoneTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }else {
            signup()
        }
        return true
    }
}

