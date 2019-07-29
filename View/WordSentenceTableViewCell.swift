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
    var contentPanel:UIView = UIView()

    var sentenceLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label;
    }()
    var translationLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
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

//        var contentPanel:UIView = UIView()
//        self.contentView .addSubview(contentPanel);

//        contentPanel.addSubview(sentenceLabel);
//        contentPanel.addSubview(translationLabel);

        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        self.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor

        contentView .addSubview(contentPanel);
        contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-1)
        }

        contentPanel.addSubview(sentenceLabel)
        contentPanel.addSubview(translationLabel)

//        contentPanel.snp.makeConstraints{ (make) -> Void in
//            make.top.left.right.equalTo(self.contentView);
//        }

        sentenceLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(contentPanel).offset(5)
            make.right.equalTo(contentPanel).offset(-5)
        }
        translationLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(contentPanel).offset(5)
            make.right.equalTo(contentPanel).offset(-5)
            make.top.equalTo(sentenceLabel.snp.bottom);
        }

//        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
//        contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
    }

    
    func setContent(_ sentence:SentenceModel){
        self.sentenceLabel.text = sentence.sentence
        self.translationLabel.text = sentence.translation

//        self.sentenceLabel.sizeToFit()
//        self.translationLabel.sizeToFit()
    }

    func getHeight(_ sentence:SentenceModel)->CGFloat{
        self.sentenceLabel.text = sentence.sentence!
        let sentenceHeight = self.sentenceLabel.actualHeight(SCREEN_WIDTH-10)
        self.translationLabel.text = sentence.translation!
        let translationHeight = self.translationLabel.actualHeight(SCREEN_WIDTH-10)

        return sentenceHeight+translationHeight+1
    }

}
