//
//  SignupViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelSignup")
        navigationItem.leftBarButtonItem = leftBarButton

    }
    
    func cancelSignup() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
