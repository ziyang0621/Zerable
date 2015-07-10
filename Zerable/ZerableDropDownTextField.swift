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
        delegate = self
        println("init code")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        println("init frame")
    }

    func setupTableView() {
        if dropDownTableView == nil {
            var tableViewFrame = frame
            tableViewFrame.origin.y += frame.size.height
            tableViewFrame.size.height = 200
            dropDownTableView = UITableView(frame: tableViewFrame)
            dropDownTableView.backgroundColor = UIColor.whiteColor()
            dropDownTableView.layer.cornerRadius = 10.0
            dropDownTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
            dropDownTableView.layer.borderWidth = 1.0
            dropDownTableView.showsVerticalScrollIndicator = false
            dropDownTableView.delegate = self
            dropDownTableView.dataSource = self
        }
        superview?.addSubview(dropDownTableView)
        superview?.bringSubviewToFront(dropDownTableView)
    }

}

extension ZerableDropDownTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        setupTableView()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.dropDownTableView.alpha = 0.7
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
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