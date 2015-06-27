//
//  SignupViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        termLabel.addGestureRecognizer(viewTap)

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSignup")
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(title: "Sign up", style: .Plain, target: self, action: "startSignup")
        navigationItem.rightBarButtonItem = rightBarButton
        
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }
    
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        let termVC = UIStoryboard.termAndPolicyViewController()
        let termNavVC = UINavigationController(rootViewController: termVC)
        presentViewController(termNavVC, animated: true, completion: nil)
    }
    
    func signup() {
        if firstnameTextField.text != "" && lastnameTextField.text != "" &&
            emailTextField.text != "" && passwordTextField.text != "" {
            if !validateEmail(emailTextField.text) {
                let alert = UIAlertController(title: "Login Failed", message: "Invalid email", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                NSUserDefaults.standardUserDefaults().setValue(emailTextField.text, forKey: "email")
                
                KeychainWrapper.sharedInstance.mySetObject(passwordTextField.text, forKey: kSecValueData)
                KeychainWrapper.sharedInstance.writeToKeychain()
                NSUserDefaults.standardUserDefaults().synchronize()
                
                dismissViewControllerAnimated(true, completion: nil)
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
    
    func cancelSignup() {
        dismissViewControllerAnimated(true, completion: nil)
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
            passwordTextField.becomeFirstResponder()
        } else {
            signup()
        }
        return true
    }
}

