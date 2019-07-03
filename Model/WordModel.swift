//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Alamofire
import Ji
import ObjectMapper
import Foundation

class WordModel: BaseJsonModel {
    var id:Int?
    var lang:Int?
    var spell:String?
    var pronounce:String?
    var meaning:String?
    var explains:[ExplainModel]?

    let df : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    override func mapping(map: Map) {
        id <- map["id"]
        lang <- map["lang"]
        spell <- map["spell"]
        pronounce <- map["pronounce"]
        meaning <- map["meaning"]
        explains <- map["explains"]

        if(explains == nil){
            explains = []
        }
    }
}
