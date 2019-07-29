//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class ArticleModel: BaseJsonModel {
    var id:Int = 0
    var lang:Int = 0
    var title:String = ""
    var performer:String = ""
    var description:String = ""
    
    var media_url:String = ""
    var media_name:String = ""
    var paragraphs = [ParagraphModel]()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        title <- map["title"]
        performer <- map["performer"]
        description <- map["description"]
        paragraphs <- map["paragraphs"]
        media_url <- map["media_url"]
        media_name <- map["media_name"]
        
        if(paragraphs == nil){
            paragraphs = []
        }
        
    }
}
