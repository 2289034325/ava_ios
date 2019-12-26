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

class ExplainModel: BaseJsonModel {
    var id:String?
    var word_id:String?
    var explain:String?
    var sentences:[SentenceModel]?

    override func mapping(map: Map) {
        id <- map["id"]
        word_id <- map["word_id"]
        explain <- map["explain"]
        sentences <- map["sentences"]
    }
}
