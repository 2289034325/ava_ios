//
//  MyWKWebView.swift
//  AVA-Swift
//
//  Created by Solin on 2019/10/7.
//  Copyright © 2019 Fin. All rights reserved.
//

import Foundation
import WebKit

class MyWKWebView:WKWebView{
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {        
        return false
    }
}
