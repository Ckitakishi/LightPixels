//
//  ImagesViewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/04.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ImagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var gallery: UICollectionView!
    
    var realm = try! Realm()
    var imageData: [Image?] = []
    var width: CGFloat? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        width = self.view.bounds.width
        
        let realm = try! Realm()

        for img in realm.objects(Image) {
            self.imageData.insert(img, atIndex: 0)
        }
        
        self.gallery.delegate = self
        self.gallery.dataSource = self
        self.gallery.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        // remove blank of fist line
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        return self.imageData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = gallery.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let tempView = UIImageView(image: UIImage(data: self.imageData[indexPath.row]!.data!))
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
        let dataCount = self.imageData.count
        var i = 0
        
        for img in realm.objects(Image) {
            i++
            if (i > dataCount) {
                print("tets")
                self.imageData.insert(img, atIndex: 0)
            }
        }
    }
    
}