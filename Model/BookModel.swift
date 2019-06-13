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

class BookModel: BaseJsonModel {
    var id:String?
    var lang:Int?
    var name:String?
    var word_count:Int?
    var finished_count:Int?
    var learning_count:Int?
    var notstart_count:Int?
    var last_learn_time:Date?
    var last_learn_count:Int?
    var answer_times:Int?
    var wrong_times:Int?
    var today_need_review_count:Int?

    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        name <- map["name"]
        word_count <- map["word_count"]
        finished_count <- map["finished_count"]
        learning_count <- map["learning_count"]
        notstart_count <- map["notstart_count"]

        last_learn_time <- (map["last_learn_time"], DateFormatterTransform(dateFormatter: df))

        last_learn_count <- map["last_learn_count"]
        answer_times <- map["answer_times"]
        wrong_times <- map["wrong_times"]

        today_need_review_count <- map["today_need_review_count"]
    }
}
