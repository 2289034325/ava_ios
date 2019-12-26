//
//  DictionaryApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Moya

enum WritingApi {
    //获取列表
    case getArticleList
    
    // 获取默写历史
    case getWritingHistory(article_id:String)
    
    //获取完整的脚本信息
    case getArticle(article_id: String)
    
    // 提交
    case submitText(history: WritingHistoryModel)
    
    // 修改得分
    case setScore(writing_id:String, score:Float)
}

extension WritingApi: V2EXTargetType {
    
    var method: Moya.Method {
        switch self {
        case .getArticleList:
            return .get
        case .getWritingHistory:
            return .get
        case .getArticle:
            return .get
        case .submitText:
            return .post
        case .setScore:
            return .put
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .getArticleList:
            return nil
        case .getWritingHistory:
            return nil
        case .getArticle:
            return nil
        case .submitText:
            return nil
        case let .setScore(writing_id, score):
            return ["writing_id":writing_id,"score":score]
        }
    }
    
    var path: String {
        switch self {
        case .getArticleList:
            return "/app/writing/article/list"
        case let .getWritingHistory(split_id):
            return "/app/writing/article/recite/\(split_id)"
        case let .getArticle(article_id):
            return "/app/writing/article/\(article_id)"
        case .submitText:
            return "/app/writing/article/recite"
        case .setScore:
            return "/app/writing/article/recite"
        }
    }

    var task: Task {
        switch self {
        case let .submitText(history):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return Task.requestCustomJSONEncodable(history,encoder:encoder)
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
