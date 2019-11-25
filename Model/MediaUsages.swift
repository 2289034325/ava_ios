//
//  Langs.swift
//  AVA-Swift
//
//  Created by Solin on 2019/10/10.
//  Copyright © 2019 Fin. All rights reserved.
//


import Foundation

enum MediaUsages {
    case ORIGIN, EXPLAIN
    var value: Int {
        switch self {
        case .ORIGIN: return 1
        case .EXPLAIN: return 2
        }
    }
    var name: String {
        switch self {
        case .ORIGIN: return "origin"
        case .EXPLAIN: return "explain"
        }
    }
    static let all = [ORIGIN, EXPLAIN]
    static func fromName(name: String) -> MediaUsages? {
        if name == "origin" {
            return .ORIGIN
        }
        if name == "explain" {
            return .EXPLAIN
        }
        return nil
    }
    static func fromValue(value: Int) -> MediaUsages? {
        if value == 1 {
            return .ORIGIN
        }
        if value == 2 {
            return .EXPLAIN
        }
        return nil
    }
}
