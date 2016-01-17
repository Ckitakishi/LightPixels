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
    var pushHistory : Bool = true
    
    var isErase : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initSetting()
        
        // remove blank of fist line
        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSetting() {
        
        var inputTextField: UITextField?
        
        let alertController: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("input_sidelength", comment: ""), preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alertController.addAction(cancelAction)
        
        let logintAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            // TODO: 摇晃动画？
            if(inputTextField!.text! != ""){
                let scaner : NSScanner = NSScanner(string: inputTextField!.text!)
                let val: UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>()
                if(scaner.scanInt(val)&&scaner.atEnd){
                    let sideLength = Int(inputTextField!.text!)!
                    if (sideLength <= 100 && sideLength > 0) {
                        self.initCanvas(sideLength);
                    }
                    else{
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                else{
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        alertController.addAction(logintAction)
        
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
            inputTextField!.keyboardType = UIKeyboardType.NumberPad
            textField.placeholder = "(0, 100]"
        }
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func initCanvas(sideLength: Int) {
        
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
        blockWidth = width / CGFloat(sideLength);
        
        for (var i: CGFloat = 0; i < CGFloat(sideLength); i++) {
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
        if gesture.state == UIGestureRecognizerState.Recognized{
            self.isErase = false
        }
    }
    
    func panHandle(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Recognized{
            self.pushHistory = true
            historyStackHandle(self.imageView.image!)
            if  self.isErase == true {
                self.isErase = false
            }
        }
        else{
            self.pushHistory = false
        }
        let location: CGPoint = gesture.locationInView(self.imageView)
        let numOfTouches = gesture.numberOfTouches()
        
        if (numOfTouches == 1) {
            
            drawRect(location)
        } else if (numOfTouches == 2) {
            
        }
        
    }
    
    func pinchHandle(gesture: UIPinchGestureRecognizer) {
        
    }
    
    func drawRect(location: CGPoint) {
        
        let width:CGFloat = self.view.bounds.width
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        self.imageView.image!.drawInRect(CGRect(x: 0, y: 0, width: width, height: width))
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        if self.isErase == false {
            CGContextSetFillColorWithColor(context, self.color.CGColor)
            CGContextFillRect (context, CGRectMake (location.x - location.x % blockWidth, location.y - location.y % blockWidth, blockWidth, blockWidth))
        }
        else{
            CGContextClearRect(context, CGRectMake (location.x - location.x % blockWidth, location.y - location.y % blockWidth, blockWidth, blockWidth))
        }
        
        
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        if self.pushHistory == true {
            historyStackHandle(self.imageView.image!)
        }
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
        
        self.isErase = true
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
        
        let firstAction = UIAlertAction(title: NSLocalizedString("save", comment: ""), style: .Default) {
            // attention
            action in
            
            self.saveInDB()
            
            let realm = try! Realm()
            if (realm.objects(Setting).count == 0) {
                try! realm.write {
                    let st = Setting()
                    realm.add(st)
                }
            }
            
            let setting = realm.objects(Setting)[0]
            
            if (setting.album) {
                if (setting.upload) {
                    UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
                    self.shouldUploadImage(self.imageView.image!)
                } else {
                     UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, "saveInfo:didFinishSavingWithError:contextInfo:", nil)
                }
            } else {
                if (setting.upload) {
                    self.shouldUploadImage(self.imageView.image!)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel) {
            action in
        }
        
        alertController.addAction(firstAction)
        
        alertController.addAction(cancelAction)
        
        //For ipad And Univarsal Device
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
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
            alert = UIAlertController(title: NSLocalizedString("success", comment: ""),
                message: NSLocalizedString("success_info", comment: ""),
                preferredStyle: .Alert)
        } else {
            alert = UIAlertController(title: NSLocalizedString("cancel", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: .Alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: {
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
        
        rImg.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
            var alert: UIAlertController
            
            if error == nil {
                alert = UIAlertController(title: NSLocalizedString("success", comment: ""),
                    message: NSLocalizedString("success_info", comment: ""),
                    preferredStyle: .Alert)

            } else {
                alert = UIAlertController(title: NSLocalizedString("cancel", comment: ""),
                    message: error?.localizedDescription,
                    preferredStyle: .Alert)
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: {
                (action:UIAlertAction!) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
}
