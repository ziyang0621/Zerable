//
//  ZerableHelperFunctions.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/25/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

func validateEmail(candidate: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
}

func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

func formattedCurrencyString(value: NSNumber) -> String {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    return formatter.stringFromNumber(value)!
}

func heightForView(text:String, #font:UIFont, #width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}