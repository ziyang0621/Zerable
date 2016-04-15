//
//  ItemPhoto.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/31/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class ItemPhoto: NSObject, NYTPhoto {
    
    var image: UIImage?
    var imageData: NSData?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    
//    init(image: UIImage?, attributedCaptionTitle: NSAttributedString) {
//        self.image = image
//        self.attributedCaptionTitle = attributedCaptionTitle
//        super.init()
//    }
    
    init(image: UIImage? = nil, imageData: NSData? = nil, attributedCaptionTitle: NSAttributedString) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }

    
//    convenience init(attributedCaptionTitle: NSAttributedString) {
//        self.init(image: nil, attributedCaptionTitle: attributedCaptionTitle)
//    }
    
}