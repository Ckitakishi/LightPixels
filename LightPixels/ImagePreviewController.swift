//
//  ImagePreviewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/10.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Parse

class ImagePreviewController: UIViewController {
    
    @IBOutlet weak var preview: UIImageView!
    var imagesData: Image? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preview.image = UIImage(data: self.imagesData!.data!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func edit(sender: UIButton) {
        
    }
    
    @IBAction func deleteImage(sender: UIButton) {
        
        let realm = try! Realm()
        try! realm.write() {
            realm.delete(imagesData!)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveToAlbum(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(self.preview.image!, self, "saveInfo:didFinishSavingWithError:contextInfo:", nil)
    }
    
    @IBAction func upload(sender: UIButton) {
        self.shouldUploadImage(self.preview.image!)
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
