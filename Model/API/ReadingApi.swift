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
    case deleteBookMark(_ bookMark:BookMarkModel)
}

extension ReadingApi: V2EXTargetType {
    var method: Moya.Method {
        switch self {
        case .bookMarkList:
            return .get
        case .editBookMark:
            return .put
        case .addBookMark:
            return .post
        case .deleteBookMark:
            return .delete
        default:
            return .get
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
            return "app/reading/bookmark/list"
        case .addBookMark:
            return "app/reading/bookmark"
        case .editBookMark:
            return "app/reading/bookmark"
        case let .deleteBookMark(bookMark):
            return "app/reading/bookmark/\(bookMark.id)"
        default:
            return ""
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
