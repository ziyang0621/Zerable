//
//  BasicInfoViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/10/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class BasicInfoViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneTextField: REFormattedNumberField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.topInset = 64
        
        phoneTextField.format = "(XXX) XXX-XXXX";
        
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        phoneTextField.delegate = self
        
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
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
