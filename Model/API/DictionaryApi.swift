//
//  DictionaryApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Moya

enum DictionaryApi {
    //获取所有词汇的统计信息
    case getMyWords
    
    // 获取某个语种的词汇
    case getLangWords(lang: Int,page_size: Int,page_index: Int)

    //学习新词
    case getNewWords(lang: Int,word_count: Int)
    //复习旧词
    case reviewOldWords(lang: Int,word_count: Int)
    //提交测试记录
    case submitResult(_ record:LearnRecordModel)
    
    //查询单词
    case searchWord(lang:Int,form:String)
}

extension DictionaryApi: V2EXTargetType {
    var method: Moya.Method {
        switch self {
        case .submitResult:
            return .post
        default:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case let .getLangWords(lang,page_size,page_index):
            return ["lang":lang,"pageSize":page_size,"currentPage":page_index]
        case let .getNewWords(lang,word_count):
            return ["lang":lang,"word_count":word_count]
        case let .reviewOldWords(lang,word_count):
            return ["lang":lang,"word_count":word_count]
        case let .searchWord(lang,form):
            return ["lang":lang,"form":form]
        default:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .getMyWords:
            return "/app/dictionary/word/stat"
        case .getLangWords:
            return "/app/dictionary/word/list"
        case let .getNewWords(lang,word_count):
            return "/app/dictionary/word/learn_new/\(lang)/\(word_count)"
        case let .reviewOldWords(lang,word_count):
            return "/app/dictionary/word/review_old/\(lang)/\(word_count)"
        case .submitResult:
            return "/app/dictionary/learn/record/save"
        case let .searchWord(lang,_):
            return "/app/dictionary/word/search"
            
        }
    }

    var task: Task {
        switch self {
        case let .submitResult(result):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return Task.requestCustomJSONEncodable(result,encoder:encoder)
        default:
            return requestTaskWithParameters
        }

    }

    var requestTaskWithParameters: Task {
        get {
            //默认参数
            var defaultParameters:[String:Any] = [:]
            //协议参数
            if let parameters = self.parameters {
                for (key, value) in parameters {
                    defaultParameters[key] = value
                }
            }
            return Task.requestParameters(parameters: defaultParameters, encoding: parameterEncoding)
        }
    }
}
