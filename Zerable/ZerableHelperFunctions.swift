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