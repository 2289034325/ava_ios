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
    // 屏蔽所有系统菜单
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(self.copy(_:))) {
            return true;
        }
        else if (action.description == "replace:") {
            // 跟 #selector(self.replace(_:withText:)) 是不同的，也不知道这个replace是从哪个类来的，所以只好用description来判断
            return true;
        }
        
        return false
    }
}
