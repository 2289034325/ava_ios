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

class MeDefaultTableViewCell: UITableViewCell {
        
    var lbl:UILabel={
        let lbl = UILabel()
        lbl.font = v2Font(18)
        
        return lbl
    }()
    
    var bl:UIView = {
        let v = UIView()
        v.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        setup()
    }
    
    func setup()->Void{
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        self.contentView.addSubview(bl)
        bl.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func bind(text:String)->Void{
        self.lbl.text = text;
    }
}
