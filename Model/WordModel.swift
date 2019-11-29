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
    var id:String?
    var lang:Int?
    var spell:String?
    var pronounce:String?
    var meaning:String?
    var explains:[ExplainModel]?
    var sentences = [SentenceModel]()
    var questions:[QuestionModel]?
    
    var last_review_time: Date?;
    var next_review_date: Date?;
    var answer_times: Int?;
    var wrong_times: Int?;

    // 记忆的第几阶段
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
                
        last_review_time <- (map["last_review_time"], DateFormatterTransform(dateFormatter: df))
        next_review_date <- (map["next_review_date"], DateFormatterTransform(dateFormatter: df))
        answer_times <- map["answer_times"]
        wrong_times <- map["wrong_times"]

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
        
        // 去除没有词形的例句
        let ss = self.sentences.filter { (st: SentenceModel) -> Bool in
            return !((st.word ?? "").isEmpty)
        }

        for (_,qt) in types.enumerated(){
            if qt == QuestionType.Fill && ss.count == 0{
                continue
            }

            let sts = ss.randomElement()

            let nq = QuestionModel(word:self,type:qt,sentence:sts,recordModel: recordModel)
            qs.append(nq)
        }

        return qs
    }
    
    func getWrongRate()->Double{
        if(self.answer_times! == 0){
            return 0.00
        }
        else{
            return Double(self.wrong_times!*100/self.answer_times!).rounded(toPlaces: 2);
        }
    }
}
