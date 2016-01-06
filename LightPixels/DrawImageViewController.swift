//
//  DrawImageViewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/04.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit
import RandomColorSwift
import RealmSwift
import Parse

class DrawImageViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var colorCollection: UICollectionView!
    @IBOutlet weak var canvasScrollView: UIScrollView!
    
    var containerView: UIView!
    var backImageView: UIImageView = UIImageView(image: nil)
    var imageView: UIImageView = UIImageView(image: nil)
    
    var width: CGFloat = 0
    var blockWidth: CGFloat = 0
    var randomColor: [Color]!
    var color: Color = UIColor.blackColor()
    
    var historyStack: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initCanvas();
        
        // remove blank of fist line
        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCanvas() {
        
        width = self.view.bounds.width
        
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        backImageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        backImageView.layer.borderWidth = 1
        let gray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        backImageView.layer.borderColor = gray.CGColor
        
        UIGraphicsBeginImageContext(backImageView.frame.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetShouldAntialias(context, false)
        
        // 格子数暂定为常量
        blockWidth = width / 16;
        
        for (var i: CGFloat = 0; i < 16; i++) {
            CGContextMoveToPoint(context, 0, i * blockWidth)
            CGContextAddLineToPoint(context, width, i * blockWidth)
            
            CGContextMoveToPoint(context, i * blockWidth, 0)
            CGContextAddLineToPoint(context, i * blockWidth, width)
            CGContextSetLineWidth(context, 1)
            CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0)
            CGContextStrokePath(context)
        }
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        backImageView.image = img
        imageView.image = UIImage()
        self.historyStackHandle(imageView.image!)
        
        UIGraphicsEndImageContext()
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchHandle:")
        canvasScrollView.addGestureRecognizer(pinchGesture)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapHandle:")
        imageView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "panHandle:")
        panGesture.maximumNumberOfTouches = 1
        imageView.addGestureRecognizer(panGesture)
        
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: "panHandle:")
        panGesture2.maximumNumberOfTouches = 1
        //        panGesture2.minimumNumberOfTouches = 2
        canvasScrollView.addGestureRecognizer(panGesture2)
        
        canvasScrollView.userInteractionEnabled = true
        imageView.userInteractionEnabled = true
        
        
        self.canvasScrollView.delegate = self
        self.canvasScrollView.minimumZoomScale = 1.0
        self.canvasScrollView.maximumZoomScale = 8.0
        self.canvasScrollView.showsHorizontalScrollIndicator = false
        self.canvasScrollView.showsVerticalScrollIndicator = false
        
        
        // 色盘初始化
        self.randomColor = randomColorsCount(24, hue: .Random, luminosity: .Light)
        self.colorCollection.delegate = self
        self.colorCollection.dataSource = self
        
        
        self.view.addSubview(canvasScrollView)
        self.canvasScrollView.addSubview(containerView)
        self.containerView.addSubview(imageView)
        self.containerView.addSubview(backImageView)
    }
    
    func tapHandle(gesture: UITapGestureRecognizer) {
        
        let location: CGPoint = gesture.locationInView(self.imageView)
        drawRect(location)
    }
    
    func panHandle(gesture: UIPanGestureRecognizer) {
        
        let location: CGPoint = gesture.locationInView(self.imageView)
        let numOfTouches = gesture.numberOfTouches()
        
        if (numOfTouches == 1) {
            
            drawRect(location)
        } else if (numOfTouches == 2) {
            print("test")
        }
    }
    
    func pinchHandle(gesture: UIPinchGestureRecognizer) {
        
    }
    
    func drawRect(location: CGPoint) {
        
        let width:CGFloat = self.view.bounds.width
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        self.imageView.image!.drawInRect(CGRect(x: 0, y: 0, width: width, height: width))
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, self.color.CGColor)

        CGContextFillRect (context, CGRectMake (location.x - location.x % blockWidth, location.y - location.y % blockWidth, blockWidth, blockWidth))
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        historyStackHandle(self.imageView.image!)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 24
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = colorCollection.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = randomColor[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.color = self.randomColor[indexPath.row]
    }
    
    @IBAction func undo(sender: UIButton) {
        if (self.historyStack.count >= 2) {
            
            UIGraphicsBeginImageContext(self.imageView.frame.size)
            self.imageView.image = self.historyStack[self.historyStack.count - 2]
            UIGraphicsEndImageContext()
            
            self.historyStack.removeLast()
        }
    }
    
    func historyStackHandle(img: UIImage) {
        if (self.historyStack.count >= 5) {
            self.historyStack.removeFirst()
        }
        self.historyStack.append(img)
    }
    
    @IBAction func clearBlock(sender: UIButton) {
        self.color = UIColor.whiteColor()
    }
   
    @IBAction func colorAllBlock(sender: UIButton) {
        let width:CGFloat = self.view.bounds.width
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        self.imageView.image!.drawInRect(CGRect(x: 0, y: 0, width: width, height: width))
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, self.color.CGColor)
        
        CGContextFillRect (context, CGRectMake (0, 0, width, width))
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        self.historyStackHandle(self.imageView.image!)
    }
    
    
    @IBAction func more(sender: UIBarButtonItem) {
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let firstAction = UIAlertAction(title: "Save To Album", style: .Default) {
            // attention
            action in UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, "saveInfo:didFinishSavingWithError:contextInfo:", nil)
            
            self.saveInDB()
        }
        
        let secondAction = UIAlertAction(title: "Upload and Share", style: .Default) {
            action in self.shouldUploadImage(self.imageView.image!)
            
            self.saveInDB()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
        }
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        //For ipad And Univarsal Device

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func saveInDB() {
        // write in realm
        
        let realm = try! Realm()
        // 每个线程只需要使用一次即可
        
        let image = Image()
        image.name = "test"
        image.id = String(NSDate().timeIntervalSince1970)
        image.data = UIImagePNGRepresentation(self.imageView.image!)
        
        // 通过事务将数据添加到 Realm 中
        try! realm.write() {
            realm.add(image)
        }
        
    }

    
    func saveInfo(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        
        var alert: UIAlertController
        
        if error == nil {
            alert = UIAlertController(title: "Success",
                message: "Your pixel art is successfully saved.",
                preferredStyle: .Alert)
            
            
        } else {
            alert = UIAlertController(title: "Fail",
                message: error?.localizedDescription,
                preferredStyle: .Alert)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action:UIAlertAction!) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }

    
    func shouldUploadImage(image: UIImage){
        let rImg = PFObject(className: "UIImage")
        
        let imgData = UIImagePNGRepresentation(image)!
        let pfImg = PFFile(data: imgData)
        rImg["png"] = pfImg
        
        print(rImg)
        rImg.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
            var alert: UIAlertController
            
            if error == nil {
                alert = UIAlertController(title: "upload success",
                    message: "Your pixel art is successfully uploaded.",
                    preferredStyle: .Alert)
                
                
            } else {
                alert = UIAlertController(title: "Fail",
                    message: error?.localizedDescription,
                    preferredStyle: .Alert)
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }

    
}
