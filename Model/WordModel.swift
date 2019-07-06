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

class WordModel: BaseJsonModel {
    var id:Int?
    var lang:Int?
    var spell:String?
    var pronounce:String?
    var meaning:String?
    var explains:[ExplainModel]?
    var sentences = [SentenceModel]()
    var questions:[QuestionModel]?

    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        spell <- map["spell"]
        pronounce <- map["pronounce"]
        meaning <- map["meaning"]
        explains <- map["explains"]

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

    func createQuestions(types:[QuestionType])->[QuestionModel]{
        var qs = [QuestionModel]()

        for (idx,qt) in types.enumerated(){
            if qt == QuestionType.Fill && self.sentences.count == 0{
                continue
            }

            let sts = self.sentences.randomElement()

            let nq = QuestionModel(word:self,type:qt,sentence:sts)
            qs.append(nq)
        }

        return qs
    }
}
