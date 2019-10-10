//
//  WordSearch.swift
//  AVA-Swift
//
//  Created by Solin on 2019/10/10.
//  Copyright © 2019 Fin. All rights reserved.
//

import ObjectMapper
import Foundation

class WordSearchModel: Mappable {
    var word: WordModel?
    var similar : [String]?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        word <- map["word"]
        similar <- map["similar"]
    }
}
