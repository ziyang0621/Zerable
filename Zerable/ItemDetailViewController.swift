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
import NYTPhotoViewer
import KVNProgress

private let kHeaderViewHeight: CGFloat = 300.0
private let kAddToCartViewHeight: CGFloat = 50.0

class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: ZerableScrollView!
    @IBOutlet weak var itemImageView: PFImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageViewTopLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var containerWidthLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var addToCartView: UIView!
    var item: PFObject!
    var headerImage: UIImage!
    var viewDidAppear = false
    var headerImageViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?
    var imageCount = 0
    var itemImages = [ItemPhoto]()
    var loadingImages = false

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        itemImageView.clipsToBounds = true
        headerImageViewFrame = itemImageView.frame
        maximumStretchHeight = CGRectGetWidth(scrollView.bounds)
        containerHeightLayoutContraint.constant = CGRectGetHeight(view.bounds)
        containerWidthLayoutContraint.constant = CGRectGetWidth(view.bounds)
        
        setupUI()
    }
    
    deinit {
        scrollView.delegate = nil
    }
    
    func setupUI() {
        itemImageView.image = headerImage
        
        itemImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "itemImageViewTapped")
        itemImageView.addGestureRecognizer(tap)
        
        itemNameLabel.text = item["name"] as? String

        generateItemRow("Price", value: formattedCurrencyString(item["price"] as! NSNumber), rowNumber: 0)
        generateItemRow("Stock", value: (item["stock"] as! NSNumber).stringValue, rowNumber: 1)
        generateItemRow("Production Date", value: (item["productionDate"] as! String), rowNumber: 2)
        generateItemRow("Durability", value: (item["durability"] as! NSNumber).stringValue + " days", rowNumber: 3)
        generateItemRow("Store Method", value: (item["storeMethod"] as! String), rowNumber: 4)
        generateItemRow("Category", value: (item["category"] as! String), rowNumber: 5)
        generateItemRow("Origin", value: (item["origin"] as! String), rowNumber: 6)
        generateItemRow("Certificate", value: (item["certificate"] as! String), rowNumber: 7)
        generateItemRow("Description", value: (item["description"] as! String), rowNumber: 8, needSeparator: false)
        
        containerHeightLayoutContraint.constant = kHeaderViewHeight + heightForView((item["description"] as! String), font:UIFont(name: "HelveticaNeue", size: 20.0)!, width: CGRectGetWidth(view.frame) - 30) + 30 * (8 * 3 + 2) + kAddToCartViewHeight
        
        addToCartView.alpha = 0.7
        if (item["stock"] as! NSNumber).intValue < 1 {
            addToCartView.backgroundColor = UIColor.lightGrayColor()
        } else {
            let addToCartTap = UITapGestureRecognizer(target: self, action: "addToCartTapped")
            addToCartView.addGestureRecognizer(addToCartTap)
        }
    }
    
    func generateItemRow(key: String, value: String, rowNumber: CGFloat, needSeparator: Bool = true) {
        generateItemInfo(key, topOffset: 20 + 30 * rowNumber * 3, textColor: UIColor.grayColor())
        generateItemInfo(value, topOffset: 20 + 30 * (rowNumber * 3 + 1), textColor: UIColor.blackColor())
        if needSeparator {
            generateSeparatorLine(20 + 30 * (rowNumber * 3 + 2), lineColor: UIColor.colorWithRGBHex(0xD7D7D7, alpha: 1.0))
        }
    }
    
    func generateItemInfo(info: String, topOffset: CGFloat, textColor: UIColor) {
        let infoLabel = UILabel()
        infoLabel.text = info
        infoLabel.textColor = textColor
        infoLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)
        infoLabel.numberOfLines = 0
        contentView.addSubview(infoLabel)
        contentView.bringSubviewToFront(infoLabel)
        infoLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let leftConstraint = NSLayoutConstraint(item: infoLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 15)
        let rightConstraint = NSLayoutConstraint(item: infoLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -15)
        let topConstraint = NSLayoutConstraint(item: infoLabel, attribute: .Top, relatedBy: .Equal, toItem: itemImageView, attribute: .Bottom, multiplier: 1, constant: topOffset)
        
        NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, topConstraint])
    }
    
    func generateSeparatorLine(topOffset: CGFloat, lineColor: UIColor) {
        let separator = UIView()
        separator.backgroundColor = lineColor
        contentView.addSubview(separator)
        contentView.bringSubviewToFront(separator)
        separator.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let leftConstraint = NSLayoutConstraint(item: separator, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 10)
        let rightConstraint = NSLayoutConstraint(item: separator, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -10)
        let heightConstraint = NSLayoutConstraint(item: separator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1)
        let topConstraint = NSLayoutConstraint(item: separator, attribute: .Top, relatedBy: .Equal, toItem: itemImageView, attribute: .Bottom, multiplier: 1, constant: topOffset)
        
        NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, heightConstraint, topConstraint])
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.containerWidthLayoutContraint.constant = CGRectGetWidth(self.view.bounds)
            self.view.updateConstraints()
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            }, completion: nil)
    }

    func addToCartTapped() {
        println("added to cart tapped")
        
        KVNProgress.showWithStatus("Adding...")
        
        PFQuery.addItemToCart(item, completion: {
            (success, error) -> () in
            KVNProgress.dismiss()
            if success {
                let cartVC = UIStoryboard.cartViewController()
                let cartNav = UINavigationController(rootViewController: cartVC)
                self.presentViewController(cartNav, animated: true, completion: nil)
            } else {
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                    println(errorString)
                }
            }
        })
    }
    
    func itemImageViewTapped() {
        if loadingImages {
            return
        }
        
        KVNProgress.showWithStatus("Loading...")
        loadingImages = true
        itemImages.removeAll(keepCapacity: false)
        
        PFQuery.loadImagesForItem(item, completion: {
            (itemImages, error) -> () in
            KVNProgress.dismiss()
            self.loadingImages = false
            if let error = error {
                let errorString = error.userInfo?["error"] as? String
                println(errorString)
            } else {
                if let images = itemImages {
                    self.itemImages = images
                    let photoViewerVC = NYTPhotosViewController(photos: self.itemImages)
                    self.presentViewController(photoViewerVC, animated: true, completion: nil)
                    
                }
            }
        })
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