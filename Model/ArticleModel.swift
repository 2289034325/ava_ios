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
    var id:String = ""
    var lang:Int = 0
    var title:String = ""
    var performer:String = ""
    var description:String = ""
    
    var paragraphs = [ParagraphModel]()
    var medias = [MediaModel]()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        title <- map["title"]
        performer <- map["performer"]
        description <- map["description"]
        paragraphs <- map["paragraphs"]
        medias <- map["medias"]
        
        if(paragraphs == nil){
            paragraphs = []
        }
        
    }
}
