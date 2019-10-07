//
//  TopicListApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Moya

enum OtherApi {
    case googleTranslate(text:String)
}

extension OtherApi: V2EXTargetType {
    var baseURL: URL {
        switch self {
        case .googleTranslate(_):
            return URL(string: "https://translate.googleapis.com/translate_a/single")!
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .googleTranslate(text):
            return ["client":"gtx","sl":"en","tl":"zh-CN","hl":"zh-CN","dt":"t","dj":"1","source":"icon","q":text]
        }
    }
    
    var path: String {
        return ""
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return requestTaskWithParameters
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
            return Task.requestParameters(parameters: defaultParameters, encoding: URLEncoding.default)
        }
    }
    
}
