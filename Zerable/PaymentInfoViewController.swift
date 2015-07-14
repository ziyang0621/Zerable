//
//  PaymentInfoViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/14/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class PaymentInfoViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cardSummaryTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.topInset = 64

        cardSummaryTextView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCardButtonPressed(sender: AnyObject) {
        
    }
}
