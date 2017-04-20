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
    
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveToAlbum(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(self.preview.image!, self, #selector(saveInfo(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func saveInfo(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        
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

}
