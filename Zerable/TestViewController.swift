//
//  TestViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/9/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var textField: ZerableDropDownTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: "tap")
        view.addGestureRecognizer(tap)
        
        textField.dataSourceDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tap() {
        textField.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension TestViewController: ZerableDropDownTextFieldDataSourceDelegate {
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = dropDownTextField.dropDownTableView.dequeueReusableCellWithIdentifier("testCell") as? UITableViewCell
        if let cell = cell {
            
        } else {
        cell = UITableViewCell(style: .Default, reuseIdentifier: "testCell")
        }
      
        cell!.textLabel!.text = "test"
        return cell!
    }

    func dropDownTextField(dropDownTextField: ZerableDropDownTextField, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

