//
//  ShareViewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/04.
//  Copyright © 2016年 chin. All rights reserved.
//

import Parse
import Foundation
import UIKit

class ShareViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var shareGallery: UICollectionView!
    var refreshControl: UIRefreshControl!
    
    var width: CGFloat? = nil
    var imageFile: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        width = self.view.bounds.width
        
        self.retrievingImage(completion: {(result: Bool) in
            
            self.shareGallery.delegate = self
            self.shareGallery.dataSource = self
        })
        
        // refresh control
        self.refreshControl = UIRefreshControl()
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.shareGallery.addSubview(self.refreshControl)
        
        // remove blank of fist line
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrievingImage(completion block: (result: Bool) -> Void) {
        
        let query = PFQuery(className:"UIImage")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["png"].getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    self.imageFile.insert(UIImage(data: imageData), atIndex: 0)
                                    if (self.imageFile.count == objects.count) {
                                        block(result: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.imageFile.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = shareGallery.dequeueReusableCellWithReuseIdentifier("shareCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let tempView = UIImageView(image: self.imageFile[indexPath.row])
        tempView.frame = CGRectMake(0, 0, (self.width! - 16) / 2, (self.width! - 16) / 2)
    
        if (cell.contentView.subviews.count > 0) {
            for uv in cell.contentView.subviews {
                uv.removeFromSuperview()
            }
        }
        cell.contentView.addSubview(tempView)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // push
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return CGSizeMake((self.width! - 16) / 2, (self.width! - 16) / 2)
    }
    
    func refresh() {
        
        // TODO: all data has been retrived, maybe slowly?
        self.imageFile = []
        self.retrievingImage(completion: {(result: Bool) in
            self.refreshControl.endRefreshing()
            self.shareGallery.reloadData()
        })
    }
    
}