//
//  ParagraphSplitEntity.swift
//  Speech
//
//  Created by 菜白 on 2018/8/4.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit

class ParagraphSplitModel: Codable {
    let id:Int
    let startIndex:Int
    let endIndex:Int
    let startTime:Float
    let endTime:Float
}
