//
//  GIFsViewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/04.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GIFsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var gallery: UICollectionView!
    
    var gifsData: [NSArray] = []
    var width: CGFloat? = nil
    var selectedGIF: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        width = self.view.bounds.width
        
        for gif in realm.objects(GIF) {
            let gifData = NSKeyedUnarchiver.unarchiveObjectWithData(gif.data!) as! [UIImage]
            self.gifsData.insert(gifData, atIndex: 0)
        }
        
        self.gallery.delegate = self
        self.gallery.dataSource = self
        self.gallery.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "GIFShowCell")
        
        // remove blank of fist line
        self.automaticallyAdjustsScrollViewInsets = false
                                                                                                                                                                                                                                                                                                                                            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.refresh()
        self.gallery.reloadData()
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.gifsData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = gallery.dequeueReusableCellWithReuseIdentifier("GIFShowCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let tempView = UIImageView()
        tempView.animationImages = self.gifsData[indexPath.row] as? [UIImage]
        tempView.animationDuration = 1.0
        tempView.startAnimating()
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
        self.selectedGIF = self.gifsData[indexPath.row]
        performSegueWithIdentifier("gifPreview", sender: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return CGSizeMake((self.width! - 16) / 2, (self.width! - 16) / 2)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "gifPreview") {
            let preview = segue.destinationViewController as! GIFPreviewController
            preview.gifData = self.selectedGIF
        }
        
    }
    
    func refresh() {
        
        let realm = try! Realm()
    
        let dataCount = self.gifsData.count
        var i = 0
        
        for gif in realm.objects(GIF) {
            i++
            if (i > dataCount) {
                let gifData = NSKeyedUnarchiver.unarchiveObjectWithData(gif.data!) as! [UIImage]
                print(gifData)
                self.gifsData.insert(gifData, atIndex: 0)

            }
        }
    }

}