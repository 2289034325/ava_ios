//
//  ParagraphSplitEntity.swift
//  Speech
//
//  Created by 菜白 on 2018/8/4.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Foundation

class BookMarkModel:Mappable,Codable{
    var id:String = ""
    var lang:Int = 0
    var name:String = ""
    var title:String = ""
    var url:String = ""
    var time:Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case lang
        case name
        case title
        case url
        case time
    }
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        name <- map["name"]
        title <- map["title"]
        url <- map["url"]
        
        time <- (map["time"], DateFormatterTransform(dateFormatter: df))
    }
}
