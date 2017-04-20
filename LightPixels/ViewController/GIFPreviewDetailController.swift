//
//  GIFPreviewDetailController.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/09.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import UIKit

class GIFPreviewDetailController: UIViewController {
    var imageData: [UIImage] = []
    @IBOutlet weak var preview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.previewAnimation()
        self.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func previewAnimation() {
        Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(play),
            userInfo: nil,
            repeats: true)
    }
    
    func play() {
        self.preview.animationImages = self.imageData
        self.preview.animationDuration = 1.0
        self.preview.startAnimating()
    }
    
}
