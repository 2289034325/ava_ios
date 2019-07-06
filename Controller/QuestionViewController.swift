//
//  LoginViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit


class QuestionViewController: UIViewController {
    var question:QuestionModel?
    var index:Int?

    var contentPanel:UIScrollView = UIScrollView()

    var spellLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(25);
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

    var sentenceLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label;
    }()

    var translationLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label;
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        self.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor

        self.view .addSubview(contentPanel);
        contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.left.right.equalTo(self.view)
        }

        switch question!.type{
        case .MF:
            setUpMF()
        case .FM:
            setUpFM()
        case .Fill:
            setUpSentence()
        }
    }

    func setUpBasic(){

        spellLabel.text = self.question?.word.spell
        pronLabel.text = self.question?.word.pronounce
        meaningLabel.text = self.question?.word.meaning

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
        }

        spellLabel.text = self.question?.word.spell
        pronLabel.text = self.question?.word.pronounce
        meaningLabel.text = self.question?.word.meaning
    }

    func setUpMF(){
        setUpBasic()
        //隐藏释意
        meaningLabel.textColor = self.contentPanel.backgroundColor

    }

    func setUpFM(){
        setUpBasic()
        //隐藏拼写和发音
        spellLabel.textColor = self.contentPanel.backgroundColor
        pronLabel.textColor = self.contentPanel.backgroundColor
    }

    func setUpSentence(){
        setUpBasic()
        meaningLabel.textColor = self.contentPanel.backgroundColor
        spellLabel.textColor = self.contentPanel.backgroundColor
        pronLabel.textColor = self.contentPanel.backgroundColor

        contentPanel.addSubview(sentenceLabel);
        sentenceLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(meaningLabel.snp.bottom).offset(5)
            make.left.equalTo(meaningLabel.snp.left)
            make.right.equalTo(contentPanel.snp.right).offset(-5)
        }

        contentPanel.addSubview(translationLabel);
        translationLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(sentenceLabel.snp.bottom).offset(5)
            make.left.equalTo(sentenceLabel.snp.left)
            make.right.equalTo(contentPanel.snp.right).offset(-5)
        }
    }
}
