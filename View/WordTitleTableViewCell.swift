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

    var spellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)!;
        return label;
    }()
    var pronLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        return label;
    }()
    var meaningLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
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

        contentView.addSubview(spellLabel);
        spellLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(5)
        }


        contentView.addSubview(pronLabel);
        pronLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(spellLabel.snp.bottom)
            make.left.equalTo(spellLabel.snp.left)
        }

        var pronImage: UIImageView = {
            let imageview = UIImageView(image: UIImage(named: "sound")?.withRenderingMode(.alwaysTemplate))
            imageview.tintColor = UIColor.blue
            imageview.contentMode = .scaleAspectFit

            return imageview
        }()
        contentView.addSubview(pronImage);
        pronImage.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(pronLabel);
            make.width.height.equalTo(12);
            make.left.equalTo(pronLabel.snp.right).offset(2);
        }

        contentView.addSubview(meaningLabel);
        meaningLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(pronLabel.snp.bottom).offset(5)
            make.left.equalTo(pronLabel.snp.left)
        }
    }

    
    func setContent(_ word:WordModel){
        spellLabel.text = word.spell
        pronLabel.text = "[\(word.pronounce!)]"
        meaningLabel.text = word.meaning!
    }

}
