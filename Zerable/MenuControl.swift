//
//  MenuControl.swift
//  Zerable
//
//  Created by Ziyang Tan on 8/27/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class MenuControl: UIControl {
    
    @IBInspectable var color: UIColor = UIColor.whiteColor() {
        didSet {
            topView.backgroundColor = color
            centerView.backgroundColor = color
            bottomView.backgroundColor = color
        }
    }
    
    var isDisplayingMenu: Bool { return centerView.alpha == 1 }
    var tapHandler: (()->())?

    private let topView = UIView()
    private let centerView = UIView()
    private let bottomView = UIView()
    
    override func didMoveToSuperview() {
        if subviews.isEmpty {
            frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 20.0)
            addTarget()
            setUp()
        }
    }
    
    override func layoutSubviews() {
        if subviews.isEmpty {
            frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 20.0)
            addTarget()
            setUp()
        }
    }
    
    func closeAnimation() {
        UIView.animateWithDuration(
            0.7,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.7,
            options: .CurveEaseOut,
            animations: {
                self.centerView.alpha = 0
                self.topView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4)*5)
                self.topView.center = self.centerView.center
                self.bottomView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4)*5)
                self.bottomView.center = self.centerView.center
            },
            completion: nil)
    }
    
    func menuAnimation() {
        UIView.animateWithDuration(
            0.7,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
            options: .CurveEaseInOut,
            animations: {
                self.centerView.alpha = 1
                self.topView.transform = CGAffineTransformIdentity
                self.bottomView.transform = CGAffineTransformIdentity
                let centerX = self.bounds.midX
                self.topView.center = CGPoint(x: centerX, y: self.topView.bounds.midY)
                self.bottomView.center = CGPoint(x: centerX, y: self.bounds.maxY - self.bottomView.bounds.midY)
            },
            completion: nil)
    }
    
    func touchUpInside() {
        isDisplayingMenu ? closeAnimation() : menuAnimation()
        tapHandler?()
    }
    
    // MARK: Private Methods
    
    private func addTarget() {
        addTarget(self, action: #selector(MenuControl.touchUpInside), forControlEvents: .TouchUpInside)
    }
    
    private func setUp() {
        backgroundColor = UIColor.clearColor()
        
        let height = CGFloat(2)
        let width = bounds.maxX
        
        topView.frame = CGRectMake(0, bounds.minY, width, height)
        topView.userInteractionEnabled = false
        topView.backgroundColor = color
        
        centerView.frame = CGRectMake(0, bounds.midY - round(height / 2), width, height)
        centerView.userInteractionEnabled = false
        centerView.backgroundColor = color
        
        bottomView.frame = CGRectMake(0, bounds.maxY - height, width, height)
        bottomView.userInteractionEnabled = false
        bottomView.backgroundColor = color
        
        addSubview(topView)
        addSubview(centerView)
        addSubview(bottomView)
    }

}
