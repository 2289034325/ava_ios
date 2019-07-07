//
//  LoginViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa


class QuestionView: UIView {
    var question:QuestionModel?
    var index:Int?

    // 如果使用UIScrollView 会导致label无法换行
    var contentPanel:UIView = UIView()

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

    init(frame: CGRect,question: QuestionModel) {
        super.init(frame: frame)

        self.question = question
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {

        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        self.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor

        self.addSubview(contentPanel);
        contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.left.right.equalTo(self)
        }

        switch question!.type{
        case .MF:
            setUpMF()
        case .FM:
            setUpFM()
        case .Fill:
            setUpSentence()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(QuestionView.viewTap(_:)))
        self.addGestureRecognizer(tap)
    }

    @objc func viewTap(_ sender:UITapGestureRecognizer) {
        switch self.question!.type{
        case .MF:
            showAnwserOfMF()
        case .FM:
            showAnserOfFM()
        case .Fill:
            showAnswerOfSentence()
        }
    }

    func setUpBasic(){

        spellLabel.text = self.question?.word.spell
        pronLabel.text = "[\(self.question!.word.pronounce!)]"
        meaningLabel.text = self.question?.word.meaning

        contentPanel.addSubview(spellLabel);
        spellLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(contentPanel)
            make.left.equalTo(contentPanel).offset(5)
        }

        contentPanel.addSubview(pronLabel);
        pronLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(spellLabel.snp.bottom)
            make.left.equalTo(spellLabel)
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
            make.left.equalTo(contentPanel).offset(5)
            make.right.equalTo(contentPanel).offset(-5)
        }
    }

    func setUpMF(){
        setUpBasic()

        pronLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        pronImage.tintColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        meaningLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        sentenceLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        translationLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
    }

    func showAnwserOfMF(){
        pronLabel.textColor = UIColor.black
        pronImage.tintColor = UIColor.blue
        meaningLabel.textColor = UIColor.black
    }

    func setUpFM(){
        setUpBasic()

        spellLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        pronImage.tintColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        pronLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        sentenceLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        translationLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
    }

    func showAnserOfFM(){

        spellLabel.textColor = UIColor.black
        pronLabel.textColor = UIColor.black
        pronImage.tintColor = UIColor.blue
    }

    func setUpSentence(){
        setUpBasic()

        spellLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        pronLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        pronImage.tintColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        meaningLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor

        contentPanel.addSubview(sentenceLabel);
        sentenceLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(meaningLabel.snp.bottom).offset(5)
            make.left.equalTo(contentPanel).offset(5)
            make.right.equalTo(contentPanel).offset(-5)
        }

        contentPanel.addSubview(translationLabel);
        translationLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(sentenceLabel.snp.bottom).offset(5)
            make.left.equalTo(contentPanel).offset(5)
            make.right.equalTo(contentPanel).offset(-5)
        }

        let wordT = self.question!.sentence!.word!
        let pl = "".leftPadding(toLength: wordT.count, withPad: "_")
        sentenceLabel.text = self.question?.sentence?.sentence?.replacingOccurrences(of: wordT, with: pl)
        translationLabel.text = self.question?.sentence?.translation

        translationLabel.textColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
    }

    func showAnswerOfSentence(){
        spellLabel.textColor = UIColor.black
        pronLabel.textColor = UIColor.black
        pronImage.tintColor = UIColor.blue
        meaningLabel.textColor = UIColor.black
        sentenceLabel.text = self.question?.sentence?.sentence
        translationLabel.textColor = UIColor.black
    }
}
