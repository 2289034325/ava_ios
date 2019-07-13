//
//  TopicListApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import Moya

enum TopicListApi {
    //获取首页列表
    case topicList(tab: String?, page: Int)
    //获取我的收藏帖子列表
    case favoriteList(page: Int)
    //获取节点主题列表
    case nodeTopicList(nodeName: String, page:Int)
}

extension TopicListApi: V2EXTargetType {

    var parameters: [String : Any]? {
        switch self {
        case let .topicList(tab, page):
            if tab == "all" && page > 0 {
                //只有全部分类能翻页
                return ["p": page]
            }
            return ["tab": tab ?? "all"]
        case let .favoriteList(page):
            return ["p": page]
        case let .nodeTopicList(_, page):
            return ["p": page]
//        default:
//            return nil
        }
    }
    
    var path: String {
        switch self {
        case let .topicList(tab, page):
            if tab == "all" && page > 0 {
                return "/recent"
            }
            return "/"
        case .favoriteList:
            return "/my/topics"
        case let .nodeTopicList(nodeName, _):
            return "/go/\(nodeName)"
//        default:
//            return ""
        }
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
            return Task.requestParameters(parameters: defaultParameters, encoding: parameterEncoding)
        }
    }
    
}
