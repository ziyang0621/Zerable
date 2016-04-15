//
//  ZerableRoundButton.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/29/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

@IBDesignable class ZerableRoundButton: UIButton {

    func setup() {
        layer.cornerRadius = CGRectGetHeight(frame) / 2
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
}
