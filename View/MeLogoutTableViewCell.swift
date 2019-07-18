//
//  UserBookListTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher
import YYText

class MeLogoutTableViewCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    func setup()->Void{
        self.textLabel?.text = "退出登陆"
    }
}
