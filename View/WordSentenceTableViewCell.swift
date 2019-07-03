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

class WordSentenceTableViewCell: UITableViewCell {

    var sentenceLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
        return label;
    }()
    var translationLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
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

//        var contentPanel:UIView = UIView()
//        self.contentView .addSubview(contentPanel);

//        contentPanel.addSubview(sentenceLabel);
//        contentPanel.addSubview(translationLabel);
        self.contentView.addSubview(sentenceLabel)
        self.contentView.addSubview(translationLabel)

//        contentPanel.snp.makeConstraints{ (make) -> Void in
//            make.top.left.right.equalTo(self.contentView);
//        }

        sentenceLabel.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(5);
        }
        translationLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(sentenceLabel);
            make.top.equalTo(sentenceLabel.snp.bottom);
        }

        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
//        contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
    }

    
    func setContent(_ sentence:SentenceModel){
        self.sentenceLabel.text = sentence.sentence
        self.translationLabel.text = sentence.translation
    }

}
