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
    
    @IBAction func close(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edit(_ sender: UIButton) {
        
    }
    
    @IBAction func deleteImage(_ sender: UIButton) {
        
        let realm = try! Realm()
        try! realm.write() {
            realm.delete(imagesData!)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveToAlbum(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(self.preview.image!, self, #selector(saveInfo(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func upload(_ sender: UIButton) {
        self.shouldUploadImage(self.preview.image!)
    }
    
    @objc func saveInfo(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo:UnsafeRawPointer) {
        
        var alert: UIAlertController
        
        if error == nil {
            alert = UIAlertController(title: "Success",
                message: "Your pixel art is successfully saved.",
                preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Fail",
                message: error?.localizedDescription,
                preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
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
                alert = UIAlertController(title: "upload success",
                    message: "Your pixel art is successfully uploaded.",
                    preferredStyle: .alert)
                
                
            } else {
                alert = UIAlertController(title: "Fail",
                    message: error?.localizedDescription,
                    preferredStyle: .alert)
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }


}
