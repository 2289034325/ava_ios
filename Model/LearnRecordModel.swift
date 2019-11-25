//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import Foundation

class LearnRecordModel:Codable {
    var id:String
    var lang:Int
    var word_count:Int
    var answer_times:Int
    var wrong_times:Int
    var start_time:Date
    var end_time:Date?
    var detail:[LearnRecordWordModel]



    init(lang:Int,word_count:Int){
        self.id = UUID().uuidString
        self.lang = lang
        self.word_count = word_count
        answer_times = 0
        wrong_times = 0
        start_time = Date()
        detail = [LearnRecordWordModel]()
    }
}
