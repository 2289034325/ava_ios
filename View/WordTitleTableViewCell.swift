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

class WordTitleTableViewCell: UITableViewCell {
    var contentPanel:UIView = UIView()

    var spellLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(25);
//        label.backgroundColor = UIColor.red
        return label;
    }()
    var pronLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        return label;
    }()
    var pronImage: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "sound")?.withRenderingMode(.alwaysTemplate))
        imageview.tintColor = UIColor.blue
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    var pronImage_height:Int = 12

    var meaningLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label;
    }()

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    func setup()->Void{

//        contentView.backgroundColor = UIColor.blue

        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        self.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor

        contentView .addSubview(contentPanel);
        contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-1)
        }

        contentPanel.addSubview(spellLabel);
        spellLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(contentPanel)
            make.left.equalTo(contentPanel).offset(5)
        }


        contentPanel.addSubview(pronLabel);
        pronLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(spellLabel.snp.bottom)
            make.left.equalTo(spellLabel.snp.left)
        }


        contentPanel.addSubview(pronImage);
        pronImage.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(pronLabel);
            make.width.height.equalTo(pronImage_height);
            make.left.equalTo(pronLabel.snp.right).offset(2);
        }

        contentPanel.addSubview(meaningLabel);
        meaningLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(pronLabel.snp.bottom).offset(5)
            make.left.equalTo(pronLabel.snp.left)
            make.right.equalTo(contentPanel.snp.right).offset(-5)
//            make.bottom.equalTo(contentView.snp.bottom)
        }
    }

    
    func setContent(_ word:WordModel){
        spellLabel.text = word.spell
        pronLabel.text = "[\(word.pronounce!)]"
        meaningLabel.text = word.meaning!

//        spellLabel.sizeToFit()
//        pronLabel.sizeToFit()
//        meaningLabel.sizeToFit()
//
//        spellLabel.setNeedsLayout()
//        pronLabel.setNeedsLayout()
//        meaningLabel.setNeedsLayout()
    }

    func getHeight(_ word:WordModel)->CGFloat{
        let spellHeight = self.spellLabel.actualHeight(SCREEN_WIDTH,word.spell!)
        let pronHeight = self.pronLabel.actualHeight(SCREEN_WIDTH,word.pronounce!)
        let meaningHeight = self.meaningLabel.actualHeight(SCREEN_WIDTH-10,word.meaning!)

        return spellHeight+pronHeight+5+meaningHeight+10
    }

}
