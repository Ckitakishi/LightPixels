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
    var imageFile: [UIImage]  = []
    var imgPFobj : [NSDate] = []
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    var selectedIndex: Int? = nil
    
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
        var count = 0;
        let query = PFQuery(className:"UIImage")
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                
                for _ in objects! {
                    self.imageFile.append(UIImage())
                }
                print("Successfully retrieved \(objects!.count) scores.")
                
                // Do something with the found objects
                
                if let objects = self.pfobjectQuickSort(objects, left: 0, right: objects!.count-2) {
                    for object in objects {
                        self.imgPFobj.insert(object.createdAt! as NSDate, atIndex: 0)
                        
                        object["png"].getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    
                                    let index = self.imgPFobj.indexOf(object.createdAt!)
                                    self.imageFile[index!]=UIImage(data: imageData)!
                                    
                                    count += 1
                                    if (count == objects.count) {
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
    
    func partition(var arr: [PFObject], left: Int, right: Int) -> Int {
        
        var temp = arr
        var l = left
        for i in (left + 1)...(right + 1) {
            let date = (temp[i].createdAt)! as NSDate
            let dateLeft = (temp[left].createdAt)! as NSDate
            
            //            print(calendar.compareDate(date, toDate: dateLeft, toUnitGranularity: NSCalendarUnit.NSSecondCalendarUnit) == NSComparisonResult.OrderedAscending)
            //            print(date.timeIntervalSince1970, dateLeft.timeIntervalSince1970, date.timeIntervalSince1970 - dateLeft.timeIntervalSince1970)
            
            if (date.timeIntervalSince1970 < dateLeft.timeIntervalSince1970) {
                l += 1
                let tempObj = temp[l]
                temp[l] = temp[i]
                temp[i] = tempObj
            }
            let t = temp[left]
            temp[left] = temp[l]
            temp[l] = t
        }
        arr = temp
        return l
    }
    
    func pfobjectQuickSort(arr: [PFObject]?, left: Int, right: Int) -> [PFObject]? {
        let index = partition(arr!, left: left, right: right)
        
        if (left < index - 1) {
            pfobjectQuickSort(arr, left: left, right: index - 1)
        }
        if (index < right) {
            pfobjectQuickSort(arr, left: index + 1, right: right)
        }
        
        return arr
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.imageFile.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = shareGallery.dequeueReusableCellWithReuseIdentifier("shareCell", forIndexPath: indexPath) as UICollectionViewCell
    
        if(indexPath.row <= imgPFobj.count-1){
            
            let tempView : UIImageView = UIImageView(image: self.imageFile[indexPath.row] as UIImage)
        
            tempView.frame = CGRectMake(0, 0, (self.width! - 16) / 2,   (self.width! - 16) / 2)
            if (cell.contentView.subviews.count > 0) {
                for uv in cell.contentView.subviews {
                    uv.removeFromSuperview()
                }
            }
            cell.contentView.addSubview(tempView)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // push, only image temporarily
//        self.selectedIndex = indexPath.row
//        performSegueWithIdentifier("sharePreview", sender: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return CGSizeMake((self.width! - 16) / 2, (self.width! - 16) / 2)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sharePreview") {
            let indexPath = self.shareGallery.indexPathForCell(sender as! UICollectionViewCell)
            let preview = segue.destinationViewController as! SharePreviewController
            preview.imageData = self.imageFile[indexPath!.row]
        }
    }
    
    func refresh() {
        // TODO: all data has been retrived, maybe slowly?
        self.imageFile = []
        self.imgPFobj = []
        self.retrievingImage(completion: {(result: Bool) in
            self.refreshControl.endRefreshing()
            self.shareGallery.reloadData()
            
        })
    }
    
}