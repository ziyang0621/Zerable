//
//  PaymentInfoViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/14/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse
import KVNProgress
import Stripe

class PaymentInfoViewController: UIViewController {

    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var paymentView: STPPaymentCardTextField!
    @IBOutlet weak var cardSummaryTextView: UITextView!
    @IBOutlet weak var saveButton: ZerableRoundButton!
    var cardInfo: UserCardInfo?
    var noCardInfo = "There is no payment card infomation in your profile"
    var toCheckout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cardSummaryTextView.layer.cornerRadius = 5
        
        paymentView.delegate = self
        paymentView.becomeFirstResponder()
        
        inputViewStyle(cardSummaryTextView)
        inputViewStyle(paymentView)
        
        if let currentUser = PFUser.currentUser() {
            PFQuery.loadUserPayment(currentUser, completion: { (cardInfo, error) -> () in
                if error == nil {
                    if let card = cardInfo {
                        self.cardInfo = card
                        let cardTypeName = card.brandName
                        self.cardSummaryTextView.text =  "\(cardTypeName)\nCard Number End With: \(card.last4)"
                    } else {
                        self.cardSummaryTextView.text = self.noCardInfo
                    }
                }
                self.checkSaveButtonState()
            })
        }
        
        if toCheckout {
            saveButton.setTitle("Next", forState: .Normal)
        } else {
            scrollView.topInset = 64
        }
        
    }
    
    func transitionToOrderSummary() {
        let orderSummaryVC = UIStoryboard.orderSummaryViewController()
        orderSummaryVC.cardInfo = cardInfo
        orderSummaryVC.cardInfoText = cardSummaryTextView.text
        showViewController(orderSummaryVC, sender: self)
    }

    @IBAction func saveButtonPressed(sender: AnyObject) {
        if toCheckout {
            if let cardInfo = cardInfo {
                println("already has card info")
                transitionToOrderSummary()
            } else {
                if let currentUser = PFUser.currentUser() {
                    
                    let userCardInfo = UserCardInfo()
                    userCardInfo.number = paymentView.card!.number!
                    userCardInfo.last4 = paymentView.card!.last4!
                    userCardInfo.expMonth = paymentView.card!.expMonth
                    userCardInfo.expYear = paymentView.card!.expYear
                    userCardInfo.cvc = paymentView.card!.cvc!
                    userCardInfo.brandName = self.getCardTypeName(paymentView.card!.brand)
                    userCardInfo.user = currentUser
                    
                    KVNProgress.showWithStatus("Saving...")
                    userCardInfo.saveInBackgroundWithBlock({
                        (succeeded: Bool, error: NSError?) -> Void in
                        KVNProgress.dismiss()
                        if let error = error {
                            let errorString = error.userInfo?["error"] as? String
                            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            self.cardInfo = userCardInfo
                            self.transitionToOrderSummary()
                        }
                    })
                }
            }
        } else {
            if let cardInfo = cardInfo {
                if cardInfo.number == paymentView.cardNumber! {
                    let alert = UIAlertController(title: "Duplicate", message: "The card you input is the same as the one you in your profile currently", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    return
                }
                
            }
            if let currentUser = PFUser.currentUser() {
                
                let userCardInfo = UserCardInfo()
                userCardInfo.number = paymentView.card!.number!
                userCardInfo.last4 = paymentView.card!.last4!
                userCardInfo.expMonth = paymentView.card!.expMonth
                userCardInfo.expYear = paymentView.card!.expYear
                userCardInfo.cvc = paymentView.card!.cvc!
                userCardInfo.brandName = self.getCardTypeName(paymentView.card!.brand)
                userCardInfo.user = currentUser
                
                KVNProgress.showWithStatus("Saving...")
                userCardInfo.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError?) -> Void in
                    KVNProgress.showSuccess()
                    if let error = error {
                        let errorString = error.userInfo?["error"] as? String
                        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.cardInfo = userCardInfo
                    }
                })
            }

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCardTypeName(cardType: STPCardBrand) -> String {
        let cardTypeName: String!
        
        switch (cardType) {
        case .Amex:
            cardTypeName = "AMEX"
        case .DinersClub:
            cardTypeName = "Dinners"
        case .Discover:
            cardTypeName = "Discover"
        case .JCB:
            cardTypeName = "JCB"
        case .MasterCard:
            cardTypeName = "Master Card"
        case .Visa:
            cardTypeName = "VISA"
        default:
            cardTypeName = ""
        }
        return cardTypeName
    }
    
    func checkSaveButtonState() {
        if toCheckout {
            saveButton.enabled = (paymentView.valid || cardInfo != nil)
            saveButton.backgroundColor = (paymentView.valid || cardInfo != nil)  ? kThemeColor : UIColor.lightGrayColor()
        } else {
            saveButton.enabled = paymentView.valid
            saveButton.backgroundColor = paymentView.valid ? kThemeColor : UIColor.lightGrayColor()
        }
    }
}

extension PaymentInfoViewController: STPPaymentCardTextFieldDelegate {
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        checkSaveButtonState()
        
        if textField.valid {
            let cardTypeName = getCardTypeName(textField.card!.brand)
            
            cardSummaryTextView.text = textField.valid ? "\(cardTypeName)\nCard Number End With: \(textField.card!.last4!)" : ""
        } else {
            if let cardInfo = cardInfo {
                cardSummaryTextView.text = "\(cardInfo.brandName)\nCard Number End With: \(cardInfo.last4)"
            } else {
                cardSummaryTextView.text = noCardInfo
            }
        }

    }
}