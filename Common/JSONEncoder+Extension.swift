//
// Created by ac on 2019-07-13.
// Copyright (c) 2019 Fin. All rights reserved.
//

import Foundation

//extension Formatter {
//    static let iso8601: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        return formatter
//    }()
//}
//
//extension JSONEncoder.DateEncodingStrategy {
//    static let iso8601withFractionalSeconds = custom {
//        var container = $1.singleValueContainer()
//        try container.encode(Formatter.iso8601.string(from: $0))
//    }
//}