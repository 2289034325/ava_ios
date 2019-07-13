//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import Foundation

struct LearnRecordWordModel:Codable {
    var word:WordModel
    var answer_times:Int
    var wrong_times:Int
    var learn_time:Date
    var learn_phase:Int
    var finished:Bool

    enum CodingKeys: String, CodingKey {
        case answer_times
        case wrong_times
        case learn_time
        case learn_phase
        case finished
    }

    init(from decoder: Decoder) {
        self.word = WordModel()

        answer_times = 0
        wrong_times = 0
        learn_time = Date()
        learn_phase = 0
        finished = false
    }

    init(word:WordModel){
        self.word = word

        answer_times = 0
        wrong_times = 0
        learn_time = Date()
        learn_phase = word.learn_phase!
        finished = false
    }
//
//    required init(from decoder:Decoder) throws {
//
//    }
}
