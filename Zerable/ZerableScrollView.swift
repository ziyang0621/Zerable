//
//  ZerableScrollView.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/26/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class ZerableScrollView: UIScrollView {
    
    var keyboardIsShown = false
    var topInset: CGFloat = 0.0
    var bottomInset: CGFloat = 0.0

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        println("init code")
        setup()
    }
    
    func setup() {
        contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        println("init frame")
        setup()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        println("show keyboard")
        if !keyboardIsShown {
            adjustInsetForKeyboardShow(true, notification: notification)
        }
        keyboardIsShown = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        println("hide keyboard")
        if keyboardIsShown {
            adjustInsetForKeyboardShow(false, notification: notification)
        }
        keyboardIsShown = false
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) -
            bottomInset + 20) * (show ? 1 : -1)
        
        contentInset.bottom += adjustmentHeight
        scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//extension ZerableScrollView: UITextFieldDelegate {
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        println("test delegate")
//        return true
//    }
//}
