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

class LearnRecordWordModel {
    var word:WordModel?
    var answer_times:Int?
    var wrong_times:Int?
    var learn_time:Date?
    var learn_phase:Int?
    var finished:Bool?
}
