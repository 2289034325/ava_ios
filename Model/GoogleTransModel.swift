//
//  GoogleTransModel.swift
//  AVA-Swift
//
//  Created by Solin on 2019/10/7.
//  Copyright © 2019 Fin. All rights reserved.
//

import Foundation
import ObjectMapper

class GoogleTransModel: BaseJsonModel {
    
    var sentences : [GoogleTransSentenceModel] = []
    
    override func mapping(map: Map) {
        sentences <- map["sentences"]
    }
    
    func getAllTrans()->String{
        var text = ""
        for mod in sentences{
            text += mod.trans!
        }
        
        return text
    }
}

class GoogleTransSentenceModel: BaseJsonModel{
    var trans: String?
    
    override func mapping(map: Map) {
        trans <- map["trans"]
    }
}

