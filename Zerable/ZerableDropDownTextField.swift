//
//  ZerableDropDownTextField.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/9/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

protocol ZerableDropDownTextFieldDataSourceDelegate: NSObjectProtocol {
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, numberOfRowsInSection section: Int) -> Int
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, didSelectRowAtIndexPath indexPath: NSIndexPath)
}

class ZerableDropDownTextField: UITextField {
    
    var dropDownTableView: UITableView!
    
    weak var dataSourceDelegate: ZerableDropDownTextFieldDataSourceDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        println("init code")
        setupTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        println("init frame")
        setupTextField()
    }
    
    func setupTextField() {
       addTarget(self, action: "editingDidBegin:", forControlEvents:.EditingDidBegin)
     //  addTarget(self, action: "editingDidEnd:", forControlEvents:.EditingDidEnd)
    }

    func setupTableView() {
        if dropDownTableView == nil {
            
            dropDownTableView = UITableView()
            dropDownTableView.backgroundColor = UIColor.whiteColor()
            dropDownTableView.layer.cornerRadius = 10.0
            dropDownTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
            dropDownTableView.layer.borderWidth = 1.0
            dropDownTableView.showsVerticalScrollIndicator = false
            dropDownTableView.delegate = self
            dropDownTableView.dataSource = self
            dropDownTableView.estimatedRowHeight = 50
            
            superview?.addSubview(dropDownTableView)
            superview?.bringSubviewToFront(dropDownTableView)
            (dataSourceDelegate as! UIViewController).view.bringSubviewToFront(dropDownTableView)
            
            dropDownTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let leftConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let rightConstraint =  NSLayoutConstraint(item: dropDownTableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
            let topConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 1)
            
            NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, heightConstraint, topConstraint])
        }

    }
    
    func editingDidBegin(textField: UITextField) {
        setupTableView()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.dropDownTableView.alpha = 1.0
        })
    }
    
    func editingDidEnd(textField: UITextField) {
        if let dropDownTableView = dropDownTableView {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.dropDownTableView.alpha = 0
            })
        }

    }

}

extension ZerableDropDownTextField: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSourceDelegate = dataSourceDelegate {
            if dataSourceDelegate.respondsToSelector(Selector("dropDownTextField:numberOfRowsInSection:")) {
                return dataSourceDelegate.dropDownTextField(self, numberOfRowsInSection: section)
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let dataSourceDelegate = dataSourceDelegate {
            if dataSourceDelegate.respondsToSelector(Selector("dropDownTextField:cellForRowAtIndexPath:")) {
                return dataSourceDelegate.dropDownTextField(self, cellForRowAtIndexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
}

extension ZerableDropDownTextField: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let dataSourceDelegate = dataSourceDelegate {
            if dataSourceDelegate.respondsToSelector(Selector("dropDownTextField:didSelectRowAtIndexPath:")) {
                 dataSourceDelegate.dropDownTextField(self, didSelectRowAtIndexPath: indexPath)
            }
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            tableView.alpha = 0
        })
    }

}