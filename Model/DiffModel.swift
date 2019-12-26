//
//  UserModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/23/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import ObjectMapper
import Foundation

class DiffModel: Mappable,Codable {
    var operation:String?
    var text:String?
        
    init(){
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        operation <- map["operation"]
        text <- map["text"]
    }
}
