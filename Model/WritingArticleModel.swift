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

class WritingArticleModel: BaseJsonModel {
    var id:String = ""
    var lang:Int = 0
    var title:String = ""
    var source:String = ""
    var description:String = ""
    var insert_time:Date?
        
    var paragraphs = [ParagraphModel]()
    var histories = [WritingHistoryModel]()
    
    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        title <- map["title"]
        source <- map["source"]
        description <- map["description"]
        insert_time <- (map["insert_time"], DateFormatterTransform(dateFormatter: df))
        paragraphs <- map["paragraphs"]
        histories <- map["histories"]
        
        if(paragraphs == nil){
            paragraphs = []
        }
        if(histories == nil){
            histories = []
        }
        
    }
}
