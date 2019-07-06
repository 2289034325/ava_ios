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

class LearnRecordModel {
    var book_id:Int?
    var word_count:Int?
    var answer_times:Int?
    var wrong_times:Int?
    var start_time:Date?
    var end_time:Date?
    var detail:[LearnRecordWordModel]?
}
