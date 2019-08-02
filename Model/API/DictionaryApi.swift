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
    //获取我的词书
    case getMyBooks
    //获取公共词书
    case getPublicBooks

    //将公共词书加入用户词书
    case addUserBook(book_id: Int)
    //自定义词书
    case saveUserBook(book: UserBookModel)
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
        case .saveUserBook:
            return .post
        default:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .getMyBooks:
            return nil
        case .getPublicBooks:
            return nil
        case .addUserBook:
            return nil
        case .saveUserBook:
            return nil
        case .restartUserBook:
            return nil
        case .deleteUserBook:
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
        case .getMyBooks:
            return "/dictionary/book/mybooks"
        case .getPublicBooks:
            return "/dictionary/book/publicbooks"
        case let .addUserBook(book_id):
            return "/dictionary/book/adduserbook/\(book_id)"
        case .saveUserBook:
            return "/dictionary/book/saveuserbook"
        case let .restartUserBook(user_book_id):
            return "/dictionary/book/restartuserbook/\(user_book_id)"
        case let .deleteUserBook(user_book_id):
            return "/dictionary/book/deleteuserbook/\(user_book_id)"
        case let .getNewWords(user_book_id,word_count):
            return "/dictionary/book/\(user_book_id)/learn_new/\(word_count)"
        case let .reviewOldWords(user_book_id,word_count):
            return "/dictionary/book/\(user_book_id)/review_old/\(word_count)"
        case .submitResult:
            return "/dictionary/learn/record/save"
//        default:
//            return ""
        }
    }

    var task: Task {
        switch self {
        case let .submitResult(result):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return Task.requestCustomJSONEncodable(result,encoder:encoder)
        case let .saveUserBook(book):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return Task.requestCustomJSONEncodable(book,encoder:encoder)
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
