//
//  DictionaryApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Moya

enum ReadingApi {
    case bookMarkList
    case editBookMark(_ bookMark:BookMarkModel)
    case addBookMark(_ bookMark:BookMarkModel)
}

extension ReadingApi: V2EXTargetType {
    var method: Moya.Method {
        switch self {
        case .bookMarkList:
            return .get
        default:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .bookMarkList:
            return nil
        default:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .bookMarkList:
            return "/bookmark/list"
        case .addBookMark:
            return "/bookmark/add"
        case .editBookMark:
            return "/bookmark/edit"
        }
    }

    var task: Task {
        switch self {
        case let .addBookMark(bookMark):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return Task.requestCustomJSONEncodable(bookMark,encoder:encoder)
        case let .editBookMark(bookMark):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return Task.requestCustomJSONEncodable(bookMark,encoder:encoder)
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
