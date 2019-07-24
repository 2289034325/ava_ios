//
//  HttpClient.swift
//  Speech
//
//  Created by 菜白 on 2018/9/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import Alamofire

class HttpClient: NSObject {
    
    static func getArticleList(complitionHandler:@escaping ([ArticleModel])->()){
        
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token") ?? ""
//        if(!JWTUtil.validateToken(token: token))
//        {
//            login { (token) in
//
//                defaults.set(token, forKey: "token")
//
//                getArticleList(complitionHandler: { (articles) in
//                    complitionHandler(articles)
//                })
//            }
//
//            return
//        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        
//        Alamofire.request(GlobalConfig.getArticleListApiUrl(), headers: headers).responseData { (response :DataResponse<Data>) in
//
//            guard response.result.isSuccess else{
//                print(response)
//
//                return
//            }
//            do{
//                let articles = try JSONDecoder().decode([ArticleEntity].self, from: response.result.value!)
//                complitionHandler(articles)
//            }
//            catch let ex
//            {
//                print(ex)
//            }
//        }
    }
    
    static func getArticle(articleId:Int, complitionHandler:@escaping (ArticleModel)->()){
        
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token") ?? ""
//        if(!JWTUtil.validateToken(token: token))
//        {
//            login { (token) in
//
//                defaults.set(token, forKey: "token")
//
//                getArticle(articleId:articleId,complitionHandler: { (article) in
//                    complitionHandler(article)
//                })
//            }
//
//            return
//        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        
//        Alamofire.request(GlobalConfig.getArticleApiUrl(articleId: articleId),headers: headers).responseData { (response :DataResponse<Data>) in
//
//            guard response.result.isSuccess else{
//                print(response)
//
//                return
//            }
//            do{
//                let article = try JSONDecoder().decode(ArticleEntity.self, from: response.result.value!)
//                complitionHandler(article)
//            }
//            catch let ex
//            {
//                print(ex)
//            }
//        }
    }
    
    static func login(complitionHandler:@escaping (String)->()){
////        ["email","speech@ac.com"],["password","freedom"]
//        Alamofire.request(GlobalConfig.getLoginUrl(), method: .post, parameters:["email":"speech@ac.com","password":"freedom"],encoding: JSONEncoding.default, headers: [:]).responseString { (response :DataResponse<String>) in
//            
//            guard response.result.isSuccess else{
//                print(response)
//                
//                return
//            }
//            
//            var token = ""
//            do{
//                let ret = convertToDictionary(text: response.result.value!)
//                token = ret!["token"] as! String
//            }
//            catch let ex
//            {
//                print(ex)
//            }
//            
//            complitionHandler(token)
//        }
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
