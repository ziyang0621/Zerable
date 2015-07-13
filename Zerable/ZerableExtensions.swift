//
//  ZerableExtensions.swift
//  Zerable
//
//  Created by Ziyang Tan on 6/23/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

extension UIView {
    class func applyCurvedShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.moveToPoint(CGPoint(x: radius, y: height))
        
        // top right
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurveToPoint(CGPoint(x: radius, y: height + depth),
            controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
            controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        let layer = view.layer
        layer.shadowPath = path.CGPath
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
}

extension UIColor {
    class func imageWithColor(color :UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(
            red: CGFloat(r / 255.0),
            green: CGFloat(g / 255.0),
            blue:CGFloat(b / 255.0),
            alpha: CGFloat(alpha))
    }
}

extension UIImage {
    func newImageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension String {
    
    func rangesOfString(findStr:String) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if contains(self, first(findStr)!) {
            // if so set this as the place to start searching
            startInd = find(self,first(findStr)!)!
        }
        else {
            // if not return empty array
            return arr
        }
        var i = distance(self.startIndex, startInd)
        while i<=count(self)-count(findStr) {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+count(findStr))] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+count(findStr))))
                i = i+count(findStr)-1
                // check again for first occurrence of character (this reduces number of times loop will run
                if contains(self[advance(self.startIndex, i)..<self.endIndex], first(findStr)!) {
                    // if so set this as the place to start searching
                    i = distance(self.startIndex,find(self[advance(self.startIndex, i)..<self.endIndex],first(findStr)!)!) + i
                    count(findStr)
                }
                else {
                    return arr
                }
                
            }
            i++
        }
        return arr
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }

    class func loginlViewController() -> LoginViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }
    
    class func signupViewController() -> SignupViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
    }
    
    class func termAndPolicyViewController() -> TermAndPolicyViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("TermAndPolicyViewController") as! TermAndPolicyViewController
    }
    
    class func itemListViewController() -> ItemListViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ItemListViewController") as! ItemListViewController
    }
    
    class func settingsViewController() -> SettingsViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
    }
    
    class func profileViewController() -> ProfileViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
    }
    
    
    class func basicViewController() -> BasicInfoViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("BasicInfoViewController") as! BasicInfoViewController
    }
    
    class func addressViewController() -> AddressViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("AddressViewController") as! AddressViewController
    }

}

extension KeychainWrapper {
    
    class var sharedInstance: KeychainWrapper {
        struct Static {
            static let instance: KeychainWrapper = KeychainWrapper()
        }
        return Static.instance
    }
}

