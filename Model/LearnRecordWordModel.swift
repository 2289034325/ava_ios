//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import Foundation

class LearnRecordWordModel:Codable {
    var word:WordModel
    var word_id:String
    var answer_times:Int
    var wrong_times:Int
    var learn_phase:Int
    var finished:Bool

    enum CodingKeys: String, CodingKey {
        case word_id
        case answer_times
        case wrong_times
        case learn_phase
        case finished
    }

    required init(from decoder: Decoder) {
        self.word = WordModel()

        word_id = ""
        answer_times = 0
        wrong_times = 0
        learn_phase = 0
        finished = false
    }

    init(word:WordModel){
        self.word = word

        word_id = word.id!
        answer_times = 0
        wrong_times = 0
        learn_phase = word.learn_phase!
        finished = false
    }
//
//    required init(from decoder:Decoder) throws {
//
//    }
}
