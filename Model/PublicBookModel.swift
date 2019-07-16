//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import Ji
import ObjectMapper
import Foundation

class PublicBookModel: BaseJsonModel {
    var id:Int = 0
    var lang:Int = 0
    var name:String = ""
    var description:String = ""
    var word_count:Int = 0
    var user_count:Int = 0

    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        name <- map["name"]
        description <- map["description"]
        word_count <- map["word_count"]
        user_count <- map["user_count"]
    }
}
