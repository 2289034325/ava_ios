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

class UserWordStatModel: BaseJsonModel {
    var lang:Int = 0
    var total_count:Int=0
    var finished_count:Int = 0
    var learning_count:Int = 0
    var notstart_count:Int = 0
    var needreview_count:Int = 0
    var last_learn_time:Date?
    var last_learn_count:Int?
        
    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    override func mapping(map: Map) {
        lang <- map["lang"]
        total_count <- map["total_count"]
        finished_count <- map["finished_count"]
        learning_count <- map["learning_count"]
        notstart_count <- map["notstart_count"]
        last_learn_time <- (map["last_learn_time"], DateFormatterTransform(dateFormatter: df))
        last_learn_count <- map["last_learn_count"]

        needreview_count <- map["needreview_count"]


    }
}
