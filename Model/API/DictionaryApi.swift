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
    //获取首页列表
    case topicList(tab: String?, page: Int)
    //获取我的收藏帖子列表
    case favoriteList(page: Int)
    //获取节点主题列表
    case nodeTopicList(nodeName: String, page:Int)

    //获取我的词书
    case getMyBooks()
    //获取公共词书
    case getPublicBooks()

    //将公共词书加入用户词书
    case addUserBook(book_id: Int)
    //重新开始学习词书
    case restartUserBook(user_book_id: Int)
    //删除词书
    case deleteUserBook(user_book_id: Int)

    //学习新词
    case getNewWords(user_book_id: Int,word_count: Int)
    //复习旧词
    case reviewOldWords(user_book_id: Int,word_count: Int)
    //提交测试记录
    case submitResult(_ record:LearnRecordModel)
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
        case let .getMyBooks():
            return nil
        case let .getPublicBooks():
            return nil
        case let .addUserBook(book_id):
            return nil
        case let .restartUserBook(user_book_id):
            return nil
        case let .deleteUserBook(user_book_id):
            return nil
        case let .getNewWords(user_book_id,word_count):
            return ["user_book_id":user_book_id,"word_count":word_count]
        case let .reviewOldWords(user_book_id,word_count):
            return ["user_book_id":user_book_id,"word_count":word_count]
        default:
            return nil
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
        case let .getMyBooks():
            return "/dictionary/book/mybooks"
        case let .getPublicBooks():
            return "/dictionary/book/publicbooks"
        case let .addUserBook(book_id):
            return "/dictionary/book/adduserbook/\(book_id)"
        case let .restartUserBook(user_book_id):
            return "/dictionary/book/restartuserbook/\(user_book_id)"
        case let .deleteUserBook(user_book_id):
            return "/dictionary/book/deleteuserbook/\(user_book_id)"
        case let .getNewWords(user_book_id,word_count):
            return "/dictionary/book/\(user_book_id)/learn_new/\(word_count)"
        case let .reviewOldWords(user_book_id,word_count):
            return "/dictionary/book/\(user_book_id)/review_old/\(word_count)"
        case let .submitResult(result):
            return "/dictionary/learn/record/save"
//        default:
//            return ""
        }
    }

    var task: Task {
        switch self {
        case let .submitResult(result):
//            let formatter = DateFormatter()
//            formatter.dateStyle = .full
//            formatter.timeStyle = .full
//            encoder.dateEncodingStrategy = .formatted(formatter)

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
