//
//  PaymentInfoViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/14/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import PaymentKit
import Parse
import KVNProgress

class PaymentInfoViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var paymentView: PTKView!
    @IBOutlet weak var cardSummaryTextView: UITextView!
    @IBOutlet weak var saveButton: ZerableRoundButton!
    var loadedCardNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.topInset = 64

        cardSummaryTextView.layer.cornerRadius = 5
        
        saveButton.enabled = false
        
        paymentView.delegate = self
        paymentView.becomeFirstResponder()
        
//        PFUser.currentUser()?.fetchIfNeededInBackgroundWithBlock({
//            (object: PFObject?, error:NSError?) -> Void in
//            let user = object as! PFUser
//            if user["payments"] != nil {
//                let userPayments = user["payments"] as! [PFObject]
//                let userPayment = userPayments.first!
//                userPayment.fetchIfNeededInBackgroundWithBlock({
//                    (payment: PFObject?, error:NSError?) -> Void in
//                    let cardDict = NSKeyedUnarchiver.unarchiveObjectWithData(payment!["cardInfo"] as! NSData) as! [String: String]
//                    self.paymentView.cardNumberField.text = cardDict["numberField"]
//                    self.paymentView.cardExpiryField.text = cardDict["expiryField"]
//                    self.paymentView.cardCVCField.text = cardDict["cvcField"]
//                    if self.paymentView.isValid() {
//                        self.saveButton.backgroundColor = kThemeColor
//                        self.saveButton.enabled = true
//                        
//                        let cardType = self.paymentView.cardNumber.cardType
//                        let cardTypeName = self.getCardTypeName(cardType)
//                        self.cardSummaryTextView.text =  "\(cardTypeName)\nCard Number End With: \(self.paymentView.cardNumber.last4)"
//                    }
//                })
//            }
//        })
        
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "UserPayment")
            query.whereKey("user", equalTo: currentUser)
            query.orderByDescending("createdAt")
            query.getFirstObjectInBackgroundWithBlock({
                (payment: PFObject?, error:NSError?) -> Void in
                let cardDict = NSKeyedUnarchiver.unarchiveObjectWithData(payment!["cardInfo"] as! NSData) as! [String: String]
                self.paymentView.cardNumberField.text = cardDict["numberField"]
                self.paymentView.cardExpiryField.text = cardDict["expiryField"]
                self.paymentView.cardCVCField.text = cardDict["cvcField"]
                self.loadedCardNumber = cardDict["number"]!
                if self.paymentView.isValid() {
                    self.saveButton.backgroundColor = kThemeColor
                    self.saveButton.enabled = true
                    
                    let cardType = self.paymentView.cardNumber.cardType
                    let cardTypeName = self.getCardTypeName(cardType)
                    self.cardSummaryTextView.text =  "\(cardTypeName)\nCard Number End With: \(self.paymentView.cardNumber.last4)"
                }
            })
        }
    }

    @IBAction func saveButtonPressed(sender: AnyObject) {
        if loadedCardNumber == paymentView.card.number {
            return
        }
        if let currentUser = PFUser.currentUser() {
            let userPayment = PFObject(className: "UserPayment")
            var paymentDict = [String: String]()
            paymentDict["number"] = paymentView.card.number
            paymentDict["cvc"] = paymentView.card.cvc
            paymentDict["addressZip"] = paymentView.card.addressZip
            paymentDict["expMonth"] = "\(paymentView.card.expMonth)"
            paymentDict["expYear"] = "\(paymentView.card.expYear)"
            paymentDict["last4"] = paymentView.card.last4
            paymentDict["numberField"] = paymentView.cardNumberField.text
            paymentDict["expiryField"] = paymentView.cardExpiryField.text
            paymentDict["cvcField"] = paymentView.cardCVCField.text
        
            userPayment["cardInfo"] = NSKeyedArchiver.archivedDataWithRootObject(paymentDict)
            userPayment["user"] = currentUser
            
            KVNProgress.showWithStatus("Saving...")
            userPayment.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                KVNProgress.showSuccess()
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                    let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.loadedCardNumber = self.paymentView.card.number
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCardTypeName(cardType: PTKCardType) -> String {
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
        return cardTypeName
    }
}

extension PaymentInfoViewController: PTKViewDelegate {
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        saveButton.enabled = valid
        saveButton.backgroundColor = valid ? kThemeColor : UIColor.lightGrayColor()
        if valid {
            let cardType = paymentView.cardNumber.cardType
            let cardTypeName = getCardTypeName(cardType)
       
            cardSummaryTextView.text = valid ? "\(cardTypeName)\nCard Number End With: \(paymentView.cardNumber.last4)" : ""
        } else {
            cardSummaryTextView.text = ""
        }
    }
}