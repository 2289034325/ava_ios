//
//  ParagraphEntity.swift
//  Speech
//
//  Created by 菜白 on 2018/7/8.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit

class ParagraphModel: Codable {
    let id:Int
    let text:String
    let translation:String
    let splits:[ParagraphSplitModel]
}
