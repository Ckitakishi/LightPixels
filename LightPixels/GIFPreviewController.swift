//
//  GIFPreviewController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/12.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class GIFPreviewController: UIViewController {
    
    @IBOutlet weak var preview: UIImageView!

    var gifData: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(gifData)
        
        self.preview.animationImages = self.gifData as? [UIImage]
        self.preview.animationDuration = 1.0
        self.preview.startAnimating()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}