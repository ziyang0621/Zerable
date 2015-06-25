//
//  TermAndPolicyViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class TermAndPolicyViewController: UIViewController {

    @IBOutlet weak var termAndPolicyTextView: UITextView!
    let segControl = UISegmentedControl(items: ["Terms", "Pravicy"])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeVC")
        navigationItem.rightBarButtonItem = rightBarButton
        
        segControl.center = CGPoint(x: CGRectGetWidth(navigationController!.navigationBar.frame) / 2,
            y: CGRectGetHeight(navigationController!.navigationBar.frame) / 2)
        segControl.addTarget(self, action: "tabChanged:", forControlEvents: .ValueChanged)
        navigationController?.navigationBar.addSubview(segControl)
    }
    
    func tabChanged(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            termAndPolicyTextView.text = "Terms of Services"
        default:
            termAndPolicyTextView.text = "Policy of Pravicy"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segControl.selectedSegmentIndex = 0
        termAndPolicyTextView.text = "Terms of Services"
    }
    
    func closeVC() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
