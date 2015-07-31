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
    var imageCount = 0
    var itemImages = [ItemPhoto]()
    var loadingImages = false

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
        
        itemImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "itemImageViewTapped")
        itemImageView.addGestureRecognizer(tap)
        
        itemNameLabel.text = item["name"] as? String
    }
    
    func itemImageViewTapped() {
        println("image tapped")
        if loadingImages {
            return
        }
        
        KVNProgress.showWithStatus("Loading...")
        loadingImages = true
        itemImages.removeAll(keepCapacity: false)
        let query = PFQuery(className: "ImageFile")
        query.whereKey("product", equalTo: item)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? String
                println(errorString)
            } else {
                if let images = objects as? [PFObject] {
                    var files = [PFFile]()
                    self.imageCount = 0
                    for image in images {
                        files.append(image["imageFile"] as! PFFile)
                        self.imageCount++
                    }
                    self.loadImageData(files)
                }
            }
        }
    }
    
    func loadImageData(files: [PFFile]) {
        var loadCount = 0
        for file in files {
            file.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        let title = NSAttributedString(string: self.item["name"] as! String, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
                        let itemImage = ItemPhoto(image: image, attributedCaptionTitle: title)
                        self.itemImages.append(itemImage)
                        loadCount++
                        if loadCount == self.imageCount {
                            KVNProgress.dismiss()
                            let photoViewerVC = NYTPhotosViewController(photos: self.itemImages)
                            self.presentViewController(photoViewerVC, animated: true, completion: nil)
                            self.loadingImages = false
                        }
                    }
                }
            })
        }
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