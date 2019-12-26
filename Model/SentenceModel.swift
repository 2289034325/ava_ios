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
import Foundation

class SentenceModel: BaseJsonModel {
    var id:String?
    var word_id:String?
    var explain_id:String?
    var word:String?
    var sentence:String?
    var translation:String?

    override func mapping(map: Map) {
        id <- map["id"]
        word_id <- map["word_id"]
        explain_id <- map["explain_id"]
        word <- map["word"]
        sentence <- map["sentence"]
        translation <- map["translation"]
    }
}
