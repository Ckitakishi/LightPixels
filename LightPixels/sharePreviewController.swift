//
//  sharePreviewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/12.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class SharePreviewController: UIViewController {
    
    @IBOutlet weak var preview: UIImageView!
    
    var imageData: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preview.image = self.imageData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveToAlbum(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(self.preview.image!, self, "saveInfo:didFinishSavingWithError:contextInfo:", nil)
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

}
