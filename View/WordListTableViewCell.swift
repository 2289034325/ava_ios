//
//  PublicBookListTableViewCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import Kingfisher
import YYText

class WordListTableViewCell: UITableViewCell {
    
    /// 拼写
    var spellLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(20)
        return label;
    }()

    /// 音标
    var soundLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(13)
        label.textColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
        return label
    }()
    
    /// 意思
    var meaningLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(13)
        return label
    }()
    
    /// 记忆阶段
    var phraseLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(10)
        label.textColor = UIColor.white
        label.layer.backgroundColor  = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
        label.layer.cornerRadius = 3
        label.textAlignment = .center
        return label
    }()
    
    /// 测试次数
    var answerTimesLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(10)
        label.textColor = UIColor.white
        label.layer.backgroundColor  = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        label.layer.cornerRadius = 3
        label.textAlignment = .center
        return label
    }()
    
    /// 错误率
    var wrongRateLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(10)
        label.textColor = UIColor.white
        label.layer.backgroundColor  = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.8017979452)
        label.layer.cornerRadius = 3
        label.textAlignment = .center
        return label
    }()
    
    var cellBottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return v
    }()

    var itemModel:WordModel?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }

    func setup()->Void{

        self.contentView .addSubview(self.spellLabel);
        self.contentView.addSubview(self.soundLabel);
        self.contentView.addSubview(self.meaningLabel);
        self.contentView.addSubview(self.phraseLabel);
        self.contentView.addSubview(self.answerTimesLabel);
        self.contentView.addSubview(self.wrongRateLabel);
        self.contentView.addSubview(self.cellBottomLine);

        self.setupLayout()

        self.backgroundColor=V2EXColor.colors.v2_CellWhiteBackgroundColor;
    }

    fileprivate func setupLayout(){
        self.spellLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.contentView).offset(10);
            make.top.equalTo(self.contentView).offset(10);
        }
        self.soundLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.spellLabel);
            make.left.equalTo(self.spellLabel.snp.right).offset(10);
        }
        self.meaningLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.spellLabel.snp.bottom).offset(5);
            make.left.equalTo(self.spellLabel);
        }
        
        self.wrongRateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.spellLabel);
            make.width.equalTo(40)
            make.right.equalTo(self.contentView).offset(-10);
        }
        self.answerTimesLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.spellLabel);
            make.width.equalTo(20)
            make.right.equalTo(self.wrongRateLabel).offset(-45);
        }
        self.phraseLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.spellLabel);
            make.width.equalTo(15)
            make.right.equalTo(self.answerTimesLabel).offset(-25);
        }
        
        self.cellBottomLine.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalTo(self.contentView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func bind(_ model:WordModel){
        self.spellLabel.text = model.spell
        self.soundLabel.text = "/\(model.pronounce!)/"
        self.meaningLabel.text = model.meaning
        self.phraseLabel.text = String(model.learn_phase!)
        self.answerTimesLabel.text = String(model.answer_times!)
        self.wrongRateLabel.text = "\(model.getWrongRate())%"
        
    }
    
    func getHeight(_ model:WordModel)->CGFloat{
        self.spellLabel.text = model.spell
        self.meaningLabel.text = model.meaning
        let h1 = self.spellLabel.actualHeight(SCREEN_WIDTH-20);
        let h2 = self.meaningLabel.actualHeight(SCREEN_WIDTH-20);
        return 10+h1+5+h2+10;
    }
}
