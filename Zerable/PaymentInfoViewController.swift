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
    @IBOutlet weak var paymentView: PTKView!
    @IBOutlet weak var cardSummaryTextView: UITextView!
    @IBOutlet weak var saveButton: ZerableRoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.topInset = 64

        cardSummaryTextView.layer.cornerRadius = 5
        
        saveButton.enabled = false
        
        paymentView.delegate = self
        paymentView.becomeFirstResponder()
    }

    @IBAction func saveButtonPressed(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PaymentInfoViewController: PTKViewDelegate {
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        saveButton.enabled = valid
        saveButton.backgroundColor = valid ? kThemeColor : UIColor.lightGrayColor()
        if valid {
            let cardType = paymentView.cardNumber.cardType
            let cardTypeName: String!
       
            switch (cardType.value) {
            case PTKCardTypeAmex.value:
                cardTypeName = "amex"
            case PTKCardTypeDinersClub.value:
                cardTypeName = "Dinners"
            case PTKCardTypeDiscover.value:
                cardTypeName = "Discover"
            case PTKCardTypeJCB.value:
                cardTypeName = "JCB"
            case PTKCardTypeMasterCard.value:
                cardTypeName = "Master Card"
            case PTKCardTypeVisa.value:
                cardTypeName = "VISA"
            default:
                cardTypeName = ""
            }
            cardSummaryTextView.text = valid ? "\(cardTypeName)\nCard Number End With: \(paymentView.cardNumber.last4)" : ""
        } else {
            cardSummaryTextView.text = ""
        }
    }
}