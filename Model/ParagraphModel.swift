//
//  ParagraphEntity.swift
//  Speech
//
//  Created by 菜白 on 2018/7/8.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class ParagraphModel: BaseJsonModel {
    var id:String = ""
    var text:String = ""
    var translation:String = ""
    var performer:String = ""
    var splits = [ParagraphSplitModel]()
    
    override func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        translation <- map["translation"]
        performer <- map["performer"]
        splits <- map["splits"]
        
        if(splits == nil){
            splits = []
        }
        
    }
}
