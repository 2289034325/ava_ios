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

class QuestionModel {
    var word:WordModel
    var type:QuestionType
    //如果是填空题，表示被选中做题的例句
    var sentence:SentenceModel?
    var answer_times:Int
    var wrong_times:Int
    var pass:Bool

    init(word:WordModel,type:QuestionType,sentence:SentenceModel?){
        self.word = word
        self.type=type
        self.answer_times = 0
        self.wrong_times = 0
        self.pass = false
        self.sentence = sentence
    }
}
