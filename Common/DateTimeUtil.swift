//
//  DateTimeUtil.swift
//  Speech
//
//  Created by 菜白 on 2018/8/13.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit

class DateTimeUtil {
    static func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
