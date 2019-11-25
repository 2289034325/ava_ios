//
//  ParagraphSplitEntity.swift
//  Speech
//
//  Created by 菜白 on 2018/8/4.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class ParagraphSplitModel: BaseJsonModel {
    var id:String = ""
    var start_index:Int = 0
    var end_index:Int = 0
    var start_time:Float = 0
    var end_time:Float = 0
    
    override func mapping(map: Map) {
        id <- map["id"]
        start_index <- map["start_index"]
        end_index <- map["end_index"]
        start_time <- map["start_time"]
        end_time <- map["end_time"]
    }
}
