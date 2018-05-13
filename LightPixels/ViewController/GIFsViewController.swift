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
        
        for gif in realm.objects(GIF.self) {
            let gifData: NSArray = NSKeyedUnarchiver.unarchiveObject(with: gif.data!) as! NSArray
            self.gifsData.insert(gifData, at: 0)
        }
        
        self.gallery.delegate = self
        self.gallery.dataSource = self
        self.gallery.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "GIFShowCell")
        
        // remove blank of fist line
        self.automaticallyAdjustsScrollViewInsets = false
                                                                                                                                                                                                                                                                                                                                            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.refresh()
        self.gallery.reloadData()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.gifsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = gallery.dequeueReusableCell(withReuseIdentifier: "GIFShowCell", for: indexPath) as UICollectionViewCell
        
        let tempView = UIImageView()
        tempView.animationImages = self.gifsData[indexPath.row] as? [UIImage]
        tempView.animationDuration = 1.0
        tempView.startAnimating()
        tempView.frame = CGRect(x: 0, y: 0, width: (self.width! - 16) / 2, height: (self.width! - 16) / 2)
        
        if (cell.contentView.subviews.count > 0) {
            for uv in cell.contentView.subviews {
                uv.removeFromSuperview()
            }
        }
        cell.contentView.addSubview(tempView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // push
        self.selectedGIF = self.gifsData[indexPath.row]
        performSegue(withIdentifier: "gifPreview", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            return CGSize(width: (self.width! - 16) / 2, height: (self.width! - 16) / 2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "gifPreview") {
            let preview = segue.destination as! GIFPreviewController
            preview.gifData = self.selectedGIF
        }
        
    }
    
    func refresh() {
        
        let realm = try! Realm()
    
        let dataCount = self.gifsData.count
        var i = 0
        
        for gif in realm.objects(GIF.self) {
            i += 1
            if (i > dataCount) {
                let gifData: NSArray = NSKeyedUnarchiver.unarchiveObject(with: gif.data!) as! NSArray
                print(gifData)
                self.gifsData.insert(gifData, at: 0)

            }
        }
    }

}
