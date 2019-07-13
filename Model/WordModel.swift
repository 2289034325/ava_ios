//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import ObjectMapper
import Foundation

class WordModel: Mappable {
    var id:Int?
    var lang:Int?
    var spell:String?
    var pronounce:String?
    var meaning:String?
    var explains:[ExplainModel]?
    var sentences = [SentenceModel]()
    var questions:[QuestionModel]?

    // 记忆的第几阶段（同一个词如果在不同的词书，可能有不同的phase）
    var learn_phase:Int?

    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    init(){
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        spell <- map["spell"]
        pronounce <- map["pronounce"]
        meaning <- map["meaning"]
        explains <- map["explains"]
        learn_phase <- map["learn_phase"]

        if(explains == nil){
            explains = []
        }
        else{
            for(idx,expl) in explains!.enumerated(){
                if expl.sentences != nil {
                    sentences.append(contentsOf: expl.sentences!)
                }
            }
        }

    }

    func createQuestions(types:[QuestionType],recordModel:LearnRecordWordModel)->[QuestionModel]{
        var qs = [QuestionModel]()

        for (idx,qt) in types.enumerated(){
            if qt == QuestionType.Fill && self.sentences.count == 0{
                continue
            }

            let sts = self.sentences.randomElement()

            let nq = QuestionModel(word:self,type:qt,sentence:sts,recordModel: recordModel)
            qs.append(nq)
        }

        return qs
    }
}
