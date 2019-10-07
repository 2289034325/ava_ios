//
//  UITextView+Extension.swift
//  AVA-Swift
//
//  Created by Solin on 2019/10/7.
//  Copyright © 2019 Fin. All rights reserved.
//

import Foundation
import UIKit

class MyTextView:UITextView{
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // 屏蔽所有系统菜单
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
