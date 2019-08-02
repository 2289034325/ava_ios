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

class UserBookModel: Mappable,Codable {
    var id:Int = 0
    var user_id:Int = 0
    var book_id:Int = 0
    var lang:Int = 0
    var name:String = ""
    var description:String = ""
    var word_count:Int = 0
    var finished_count:Int = 0
    var learning_count:Int = 0
    var notstart_count:Int = 0
    var last_learn_time:Date?
    var last_learn_count:Int?
    var answer_times:Int = 0
    var wrong_times:Int = 0
    var today_need_review_count:Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case lang
        case name
        case description
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
        user_id <- map["user_id"]
        book_id <- map["book_id"]
        lang <- map["lang"]
        name <- map["name"]
        description <- map["description"]
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
