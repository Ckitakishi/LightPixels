//
//  DrawGIFViewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/07.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit
import RandomColorSwift
import RealmSwift
import Parse
import ImageIO
import MobileCoreServices
import AssetsLibrary

class DrawGIFViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var canvasScrollView: UIScrollView!
    @IBOutlet weak var colorCollection: UICollectionView!
    @IBOutlet weak var frameCollection: UICollectionView!
    @IBOutlet weak var goToPreview: UIButton!
    
    var containerView: UIView!
    var backImageView: UIImageView = UIImageView(image: nil)
    var imageView: UIImageView = UIImageView(image: nil)
    
    var width: CGFloat = 0
    var blockWidth: CGFloat = 0
    var randomColor: [Color]!
    var color: Color = UIColor.black
    
    var historyStack: [UIImage] = []
    var frameContainer: [UIImage] = []
    
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
        
        let alertController: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("input_sidelength", comment: ""), preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("fail", comment: ""), style: .cancel) { action -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        
        let logintAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { action -> Void in
            if(inputTextField!.text! != ""){
                let scaner : Scanner = Scanner(string: inputTextField!.text!)
                let val: UnsafeMutablePointer<Int32>? = nil
                if(scaner.scanInt32(val)&&scaner.isAtEnd){
                    let sideLength = Int(inputTextField!.text!)!
                    if (sideLength <= 100 && sideLength > 0 && inputTextField!.text! != "") {
                        self.initCanvas(sideLength);
                    }
                    else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(logintAction)
        
        alertController.addTextField { textField -> Void in
            inputTextField = textField
            inputTextField!.keyboardType = UIKeyboardType.numberPad
            textField.placeholder = "(0, 100]"
        }
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func initCanvas(_ sideLength: Int) {
        
        width = self.view.bounds.width
        
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        backImageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        backImageView.layer.borderWidth = 1
        let gray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        backImageView.layer.borderColor = gray.cgColor
        
        UIGraphicsBeginImageContext(backImageView.frame.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(false)
        
        // 格子数暂定为常量
        blockWidth = width / CGFloat(sideLength);
        
        var i: CGFloat = 0
        while(i < CGFloat(sideLength)) {
            context.move(to: CGPoint(x: 0, y: i * blockWidth))
            context.addLine(to: CGPoint(x: width, y: i * blockWidth))
            
            context.move(to: CGPoint(x: i * blockWidth, y: 0))
            context.addLine(to: CGPoint(x: i * blockWidth, y: width))
            context.setLineWidth(1)
            context.setStrokeColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            context.strokePath()
            i += 1
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        backImageView.image = img
        imageView.image = UIImage()
        self.historyStackHandle(imageView.image!)
        
        UIGraphicsEndImageContext()
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandle(_:)))
        canvasScrollView.addGestureRecognizer(pinchGesture)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        panGesture.maximumNumberOfTouches = 1
        imageView.addGestureRecognizer(panGesture)
        
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        panGesture2.maximumNumberOfTouches = 1
        //        panGesture2.minimumNumberOfTouches = 2
        canvasScrollView.addGestureRecognizer(panGesture2)
        
        canvasScrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        
        
        self.canvasScrollView.delegate = self
        self.canvasScrollView.minimumZoomScale = 1.0
        self.canvasScrollView.maximumZoomScale = 8.0
        self.canvasScrollView.showsHorizontalScrollIndicator = false
        self.canvasScrollView.showsVerticalScrollIndicator = false
        
        
        // 色盘初始化
        self.randomColor = randomColors(count: 24, hue: .random, luminosity: .light)
        self.colorCollection.delegate = self
        self.colorCollection.dataSource = self
        
        self.frameCollection.delegate = self
        self.frameCollection.dataSource = self
        
        self.view.addSubview(canvasScrollView)
        self.canvasScrollView.addSubview(containerView)
        self.containerView.addSubview(imageView)
        self.containerView.addSubview(backImageView)
        
        self.goToPreview.isEnabled = false
    }
    
    func tapHandle(_ gesture: UITapGestureRecognizer) {
        
        let location: CGPoint = gesture.location(in: self.imageView)
        drawRect(location)
    }
    
    func panHandle(_ gesture: UIPanGestureRecognizer) {
        
        let location: CGPoint = gesture.location(in: self.imageView)
        let numOfTouches = gesture.numberOfTouches
        
        if (numOfTouches == 1) {
            
            drawRect(location)
        } else if (numOfTouches == 2) {
            print("test")
        }
    }
    
    func pinchHandle(_ gesture: UIPinchGestureRecognizer) {
        
    }
    
    func drawRect(_ location: CGPoint) {
        
        let width:CGFloat = self.view.bounds.width
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        self.imageView.image!.draw(in: CGRect(x: 0, y: 0, width: width, height: width))
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.color.cgColor)
        
        context.fill (CGRect (x: location.x - location.x.truncatingRemainder(dividingBy: blockWidth), y: location.y - location.y.truncatingRemainder(dividingBy: blockWidth), width: blockWidth, height: blockWidth))
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        historyStackHandle(self.imageView.image!)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.colorCollection) {
            return 24
        } else {
            return self.frameContainer.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == self.colorCollection) {
            let cell = self.colorCollection.dequeueReusableCell(withReuseIdentifier: "gifColorCell", for: indexPath) as UICollectionViewCell
            cell.backgroundColor = randomColor[indexPath.row]
            return cell
        } else {
            let cell = self.frameCollection.dequeueReusableCell(withReuseIdentifier: "gifFrameCell", for: indexPath) as UICollectionViewCell
           
            let tempView = UIImageView(image: self.frameContainer[indexPath.row])
            tempView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
            
            if (cell.contentView.subviews.count > 0) {
                for uv in cell.contentView.subviews {
                    uv.removeFromSuperview()
                }
            }
            
            cell.contentView.addSubview(tempView)
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.gray.cgColor
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.color = self.randomColor[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if (self.historyStack.count >= 2) {
            
            UIGraphicsBeginImageContext(self.imageView.frame.size)
            self.imageView.image = self.historyStack[self.historyStack.count - 2]
            UIGraphicsEndImageContext()
            
            self.historyStack.removeLast()
        }
    }
    
    func historyStackHandle(_ img: UIImage) {
        if (self.historyStack.count >= 5) {
            self.historyStack.removeFirst()
        }
        self.historyStack.append(img)
    }
    
    @IBAction func clearBlock(_ sender: UIButton) {
        self.color = UIColor.white
    }
    
    @IBAction func colorAllBlock(_ sender: UIButton) {
        let width:CGFloat = self.view.bounds.width
        
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        self.imageView.image!.draw(in: CGRect(x: 0, y: 0, width: width, height: width))
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.color.cgColor)
        
        context.fill (CGRect (x: 0, y: 0, width: width, height: width))
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        self.historyStackHandle(self.imageView.image!)
    }
    
    
    @IBAction func more(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var gifData: Data?
        
        self.createGIF(with: self.frameContainer, loopCount: 1, frameDelay: 0.125) { (data, error) -> () in
            if data != nil {
                gifData = data
            }
        }
        
        let firstAction = UIAlertAction(title: NSLocalizedString("save", comment: ""), style: .default) {
            // attention
            action in
            
            self.saveInDB(self.frameContainer)
            
            let realm = try! Realm()
            if (realm.objects(Setting.self).count == 0) {
                try! realm.write {
                    let st = Setting()
                    realm.add(st)
                }
            }
            
            let setting = realm.objects(Setting.self)[0]
            
            if (setting.album) {
                if (setting.upload) {
                    ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: gifData, metadata: nil, completionBlock: { (assetURL: URL!, error: Error!) -> Void in
//                        self.shouldUploadImage(gifData)
                    })
                } else {
                    ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: gifData, metadata: nil, completionBlock: { (assetURL: URL!, error: Error!) -> Void in
                        self.saveInfo(error! as NSError)
                    })
                }
            } else {
                if (setting.upload) {
//                    self.shouldUploadImage(gifData)
                } else {
                    self.navigationController?.popViewController(animated: true)

                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) {
            action in
        }

        alertController.addAction(firstAction)
        alertController.addAction(cancelAction)
        
        //For ipad And Univarsal Device
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func saveInDB(_ gifData: [UIImage]) {
        
        let realm = try! Realm()
        // 每个线程只需要使用一次即可
        
        let gif = GIF()
        gif.name = "test"
        gif.id = String(Date().timeIntervalSince1970)
        gif.data = NSKeyedArchiver.archivedData(withRootObject: gifData)
        
        // 通过事务将数据添加到 Realm 中
        try! realm.write() {
            realm.add(gif)
        }
        
    }
    
    
    func saveInfo(_ error: NSError?) {
        
        var alert: UIAlertController
        
        if error == nil {
            alert = UIAlertController(title: NSLocalizedString("success", comment: ""),
                message: NSLocalizedString("success_info", comment: ""),
                preferredStyle: .alert)
            
            
        } else {
            alert = UIAlertController(title: NSLocalizedString("cancel", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    func shouldUploadImage(_ image: UIImage){
        let rImg = PFObject(className: "UIImage")
        
        let imgData = UIImagePNGRepresentation(image)!
        let pfImg = PFFile(data: imgData)
        rImg["png"] = pfImg
        
        rImg.saveInBackground { (success : Bool, error : Error?) -> Void in
            var alert: UIAlertController
            
            if error == nil {
                alert = UIAlertController(title: NSLocalizedString("success", comment: ""),
                    message: NSLocalizedString("success_info", comment: ""),
                    preferredStyle: .alert)
                
                
            } else {
                alert = UIAlertController(title: NSLocalizedString("cancel", comment: ""),
                    message: error?.localizedDescription,
                    preferredStyle: .alert)
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func addFrame(_ sender: UIButton) {
        
        self.frameContainer.append(self.imageView.image!)
        self.frameCollection.reloadData()
        if self.goToPreview.isEnabled == false {
            self.goToPreview.isEnabled = true
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "preview") {
            let preview = segue.destination as! GIFPreviewDetailController;
            preview.imageData = self.frameContainer
        }
    }
    

    // based on https://gist.github.com/westerlund/eae8ec71cdac88be7c3a
    func createGIF(with images: [UIImage], loopCount: Int, frameDelay: Double, completion: (_ data: Data?, _ error: Error) -> ()) {
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let sourceURL: URL? = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("animated.gif")
        
        if let url = sourceURL as CFURL? {
            let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil)
            CGImageDestinationSetProperties(destination!, fileProperties as CFDictionary)
            
            for i in 0...images.count-1 {
                CGImageDestinationAddImage(destination!, images[i].cgImage!, frameProperties as CFDictionary)
            }
            
            if CGImageDestinationFinalize(destination!) {
                do {
                    let data = try Data(contentsOf: sourceURL!)
                    completion(data, createGIFError.NONError)
                } catch {
                    completion(nil, createGIFError.DataInitError)
                }
            } else {
                completion(nil, createGIFError.FinalizeError)
            }
        } else  {
            completion(nil, createGIFError.URLError)
        }
    }

    
}
