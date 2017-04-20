//
//  Image.swift
//  LightPixels
//
//  Created by PC731 on 2016/01/04.
//  Copyright © 2016年 chin. All rights reserved.
//

import Foundation
import RealmSwift

class Image: Object {
    dynamic var name = ""
    dynamic var id = ""
    dynamic var data: Data? = nil
    
    override static func primaryKey() -> String? {
        return "id";
    }
}
