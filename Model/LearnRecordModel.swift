//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import Foundation

struct LearnRecordModel:Codable {
    var id:String
    var book_id:Int
    var word_count:Int
    var answer_times:Int
    var wrong_times:Int
    var start_time:Date
    var end_time:Date?
    var detail:[LearnRecordWordModel]



    init(book_id:Int,word_count:Int){
        self.id = UUID().uuidString
        self.book_id = book_id
        self.word_count = word_count
        answer_times = 0
        wrong_times = 0
        start_time = Date()
        detail = [LearnRecordWordModel]()
    }
}
