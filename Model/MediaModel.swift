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

class MediaModel: BaseJsonModel {
    var id:String = ""
    var name:String = ""
    var path:String = ""
    var usage:Int = 0
    var time:Float = 0
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        path <- map["path"]
        usage <- map["usage"]
        time <- map["time"]
    }
    
    func getDownloadUrl() -> String{
        return "\(API_BASE_URL)/app/speech/article/media/\(id)"
    }
}
