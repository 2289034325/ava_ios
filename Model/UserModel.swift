//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class UserModel: BaseJsonModel {
    var status:String?
    var id:String?
    var url:String?
    var username:String?
    var website:String?
    var twitter:String?
    var psn:String?
    var btc:String?
    var location:String?
    var tagline:String?
    var bio:String?
    var avatar_mini:String?
    var avatar_normal:String?
    var avatar_large:String?
    var created:String?
    
    override func mapping(map: Map) {
        status <- map["status"]
        id <- map["id"]
        url <- map["url"]
        username <- map["username"]
        website <- map["website"]
        twitter <- map["twitter"]
        psn <- map["psn"]
        btc <- map["btc"]
        location <- map["location"]
        tagline <- map["tagline"]
        bio <- map["bio"]
        avatar_mini <- map["avatar_mini"]
        avatar_normal <- map["avatar_normal"]
        avatar_large <- map["avatar_large"]
        created <- map["created"]
    }
}

//MARK: - Request
extension UserModel{
    /**
     登录
     
     - parameter username:          用户名
     - parameter password:          密码
     - parameter once:              once
     - parameter completionHandler: 登录回调
     */

    class func Login(_ username:String,password:String ,
                     code:String,loginTicket:String,
                     completionHandler: @escaping (V2ValueResponse<String>, Bool) -> Void){
        let prames = [
            "password": password,
            "username": username
        ]

        var dict = MOBILE_CLIENT_HEADERS
        dict["content-type"] = "application/json"
        //为安全，此处使用https
        var loginUrl = API_BASE_URL+"/auth/login/"+loginTicket+"/"+code
        //登录
        Alamofire.request(loginUrl,method:.post, parameters: prames, encoding: JSONEncoding.default,headers: dict).responseString{
            (response) -> Void in

            var statusCode = response.response?.statusCode
            if(statusCode != 200){
                var error_msg:String = "后台系统发生错误"
                if let msg = response.response?.allHeaderFields["msg-content"]{
                    error_msg = (msg as! String).removingPercentEncoding!
                }

                completionHandler(V2ValueResponse(success: false,message: error_msg),false)
            }
            else{
                var res = response.result.value!
                completionHandler(V2ValueResponse(value: res, success: true),false)
            }
        }
    }
    
    class func getUserInfoFromToken(_ token:String ,completionHandler:((V2ValueResponse<UserModel>) -> Void)? ){


    }
    
}
