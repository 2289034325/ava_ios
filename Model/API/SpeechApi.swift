//
//  DictionaryApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Moya

enum SpeechApi {
    //获取首页列表
    case getSpeechList()
}

extension SpeechApi: V2EXTargetType {
    var method: Moya.Method {
//        switch self {
//        case .submitResult:
//            return .post
//        default:
//            return .get
//        }
        
        return .get
    }

    var parameters: [String : Any]? {
        switch self {
        case .getSpeechList():
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .getSpeechList():
            return "/speech/article/list"
        }
    }

    var task: Task {
//        switch self {
//        default:
//            return requestTaskWithParameters
//        }
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
            return Task.requestParameters(parameters: defaultParameters, encoding: parameterEncoding)
        }
    }
}
