//
//  ItemDetailViewController.swift
//  Zerable
//
//  Created by Ziyang Tan on 7/31/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import Parse
import ParseUI

private let kHeaderViewHeight: CGFloat = 300.0

class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var itemImageView: PFImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageViewTopLayoutContraint: NSLayoutConstraint!
    var item: PFObject!
    var headerImage: UIImage!
    var viewDidAppear = false
    var headerImageViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        itemImageView.clipsToBounds = true
        headerImageViewFrame = itemImageView.frame
        maximumStretchHeight = CGRectGetWidth(scrollView.bounds)
        
        setupUI()
    }
    
    func setupUI() {
        itemImageView.image = headerImage
        itemNameLabel.text = item["name"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }
    
    func updateHeaderImageView() {
        let insets = scrollView.contentInset
        let offset = scrollView.contentOffset
        let minY = -insets.top
        if offset.y < minY {
            let deltaY = fabs(offset.y - minY)
            var frame = headerImageViewFrame
            frame.size.height = min(max(minY, kHeaderViewHeight + deltaY), maximumStretchHeight!)
            frame.origin.y = CGRectGetMinY(frame) - deltaY
            headerImageViewTopLayoutContraint.constant = frame.origin.y
            headerImageViewHeightLayoutConstraint.constant = frame.size.height
        }
    }

}

extension ItemDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if viewDidAppear {
            updateHeaderImageView()
        }
    }
}