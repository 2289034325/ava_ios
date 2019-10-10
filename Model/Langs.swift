//
//  Langs.swift
//  AVA-Swift
//
//  Created by Solin on 2019/10/10.
//  Copyright © 2019 Fin. All rights reserved.
//

import Foundation

enum Lang {
    case EN, JP, KR, FR
    var id: Int {
        switch self {
        case .EN: return 1
        case .JP: return 2
        case .KR: return 3
        case .FR: return 4
        }
    }
    var code: String {
        switch self {
        case .EN: return "EN"
        case .JP: return "JP"
        case .KR: return "KR"
        case .FR: return "FR"
        }
    }
    var name: String {
        switch self {
        case .EN: return "English"
        case .JP: return "日本語"
        case .KR: return "한국어"
        case .FR: return "français"
        }
    }
    static let all = [EN, JP, KR, FR]
    static func fromName(name: String) -> Lang? {
        if name == "English" {
            return .EN
        }
        if name == "日本語" {
            return .JP
        }
        if name == "한국어" {
            return .KR
        }
        if name == "français" {
            return .FR
        }
        return nil
    }
    static func fromId(id: Int) -> Lang? {
        if id == 1 {
            return .EN
        }
        if id == 2 {
            return .JP
        }
        if id == 3 {
            return .KR
        }
        if id == 4 {
            return .FR
        }
        return nil
    }
    mutating func next() {
        switch self {
        case .EN:
            self = .JP
        case .JP:
            self = .KR
        case .KR:
            self = .FR
        case .FR:
            self = .EN
        }
    }
}
