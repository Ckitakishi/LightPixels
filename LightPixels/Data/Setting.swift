//
//  Setting.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/11.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import RealmSwift

class Setting: Object {
    @objc dynamic var album = true
    @objc dynamic var upload = true
}
