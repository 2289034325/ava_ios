//
// Created by ac on 2019-06-10.
// Copyright (c) 2019 Fin. All rights reserved.
//

import Foundation

extension Date {
    func toShortString() -> String{
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="MM/dd HH:mm"
        return dfmatter.string(from: self)
    }
    
    func toFullString() -> String{
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy/MM/dd HH:mm:ss"
        return dfmatter.string(from: self)
    }
    
    func toRelativeString() -> String {
        //时间差
        let reduceTime : TimeInterval = Date().timeIntervalSince(self)
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        let months = Int(reduceTime / 3600 / 24 / 30)
        if months < 12 {
            return "\(months)个月前"
        }
        else{
        let years = Int(reduceTime / 3600 / 24 / 30 / 12)
            return "\(years)年前"
        }
        
        //不满足上述条件---或者是未来日期-----直接返回日期
//        let dfmatter = DateFormatter()
//        dfmatter.dateFormat="yyyy/MM/dd HH:mm:ss"
//        return dfmatter.string(from: self)
    }
}
