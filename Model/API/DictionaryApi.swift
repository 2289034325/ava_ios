//
//  DictionaryApi.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2018/9/17.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit

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
}

extension DictionaryApi: V2EXTargetType {
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
            return ["book_id":book_id]
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
        case let .getMyBooks():
            return "/dictionary/book/mybooks"
        case let .getPublicBooks():
            return "/dictionary/book/publicbooks"
        case let .addUserBook(book_id):
            return "/dictionary/book/adduserbook/\(book_id)"
//        default:
//            return ""
        }
    }
    
    
}
