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
    var topInset: CGFloat = 0.0 {
        didSet {
            adjustInsets()
        }
    }
    var bottomInset: CGFloat = 0.0 {
        didSet {
            adjustInsets()
        }
    }

    var leftInset: CGFloat = 0.0 {
        didSet {
            adjustInsets()
        }
    }

    var rightInset: CGFloat = 0.0 {
        didSet {
            adjustInsets()
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        println("init code")
        setup()
    }
    
    func adjustInsets() {
        contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
    
    func setup() {
        contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        
        let viewTap = UITapGestureRecognizer(target: self, action: "viewTapped:")
        addGestureRecognizer(viewTap)
        viewTap.cancelsTouchesInView = false

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        println("init frame")
        setup()
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
            bottomInset + 20) * (show ? 1 : -1)
        
        contentInset.bottom += adjustmentHeight
        scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func findFirstResponder(view: UIView) -> UIView? {
        for childView in view.subviews {
            if childView.respondsToSelector(Selector("isFirstResponder")) &&
                childView.isFirstResponder() {
                    return childView as? UIView
            }
            if let result = findFirstResponder(childView as! UIView) {
                return result;
            }
        }
        return nil
    }
    
    func dismissKeyboard() {
        if let childView = findFirstResponder(self) {
            childView.resignFirstResponder()
        }
    }
    
    func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
