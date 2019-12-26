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

class UserWordStatListTableViewCell: UITableViewCell {
    
    /// 语言国旗
    var avatarImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode=UIViewContentMode.scaleAspectFit
        return imageview
    }()
    
    /// 语种名称
    var langNameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        return label;
    }()
    
    /// 进度条
    var progressBar: UIView = {
        let v = UIView()
        return v
    }()
    
    /// 上次学习日期和数量
    var dateAndLastLearnedLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        label.textColor = UIColor.gray
        return label
    }()
    /// 总单词数量
    var wordCountLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(20)
        return label
    }()
    var wordCountIconImageView: UIImageView = {
        let img = UIImage(from: .segoeMDL2, code: "Dictionary", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        let imageview = UIImageView(image: img)
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    ///今天需要复习的数量
    var todayNeedReviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(60)
        label.textColor = UIColor.darkGray
        return label
    }()

    /// 已掌握，学习中，未学习
    var progressLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(18)
        label.numberOfLines=0
        return label
    }()
    
    var notStartCountLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        label.textColor = UIColor.gray
        return label
    }()
    var learningCountLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        label.textColor = UIColor.gray
        return label
    }()
    var finishedCountLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        label.textColor = UIColor.gray
        return label
    }()
        
    var itemModel:UserWordStatModel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    
    func setup()->Void{
        let leftContainer : UIView = {
            let v = UIView()
            
            return v
        }()
        self.contentView.addSubview(leftContainer);
        leftContainer.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(150)
        }
        
        leftContainer.addSubview(self.avatarImageView);
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalToSuperview()
            make.height.equalTo(30);
            make.width.equalTo(40);
        }
        leftContainer.addSubview(self.langNameLabel);
        self.langNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(avatarImageView.snp.right).offset(5)
            make.top.equalToSuperview()
        }
        leftContainer.addSubview(self.dateAndLastLearnedLabel)
        dateAndLastLearnedLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(avatarImageView.snp.right).offset(5)
            make.bottom.equalTo(avatarImageView)
        }
        
        leftContainer.addSubview(self.todayNeedReviewCountLabel);
        self.todayNeedReviewCountLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.centerX.equalToSuperview()
        }
        
//        let todayNeedReviewLabel: UILabel = {
//            let label = UILabel()
//            label.text = "today need review"
//            label.font = v2Font(10)
//            label.textColor = UIColor.gray
//            return label
//        }()
//        leftContainer.addSubview(todayNeedReviewLabel)
//        todayNeedReviewLabel.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(todayNeedReviewCountLabel.snp.bottom).offset(-10)
//            make.centerX.equalTo(todayNeedReviewCountLabel)
//        }
        
//        let leftBottomLine:UIView = {
//            let v = UIView()
//            v.backgroundColor = #colorLiteral(red: 0.9170066714, green: 0.9170066714, blue: 0.9170066714, alpha: 1)
//            return v
//        }()
//        leftContainer.addSubview(leftBottomLine);
//        leftBottomLine.snp.makeConstraints{ (make) -> Void in
//            make.left.bottom.right.equalToSuperview()
//            make.height.equalTo(1)
//        }
        
        /************************************************************************/
        
        let rightContainer = UIView()
        self.contentView.addSubview(rightContainer);
        rightContainer.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(leftContainer.snp.right)
            make.top.equalToSuperview().offset(5)
            make.right.bottom.equalToSuperview().offset(-5)
        }
        let wordCountTextLabel:UILabel = {
            let label = UILabel()
            label.text = "Total"
            label.font = v2Font(20)
            return label
        }()
        rightContainer.addSubview(wordCountTextLabel);
        wordCountTextLabel.snp.makeConstraints{ (make) -> Void in
            make.top.left.equalToSuperview()
        }
        rightContainer.addSubview(wordCountLabel);
        wordCountLabel.snp.makeConstraints{ (make) -> Void in
            make.top.right.equalToSuperview()
        }
        let splitBar:UIView = {
            let v = UIView()
            v.backgroundColor = V2EXColor.colors.v2_backgroundColor
            return v
        }()
        rightContainer.addSubview(splitBar);
        splitBar.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(wordCountTextLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.3)
        }
        
        let notStartCountTextLabel: UILabel = {
            let label = UILabel()
            label.text = "NotStart"
            label.font=v2Font(12)
            label.textColor = UIColor.gray
            return label
        }()
        rightContainer.addSubview(notStartCountTextLabel);
        notStartCountTextLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(splitBar.snp.bottom).offset(5)
            make.left.equalToSuperview()
        }
        rightContainer.addSubview(notStartCountLabel);
        notStartCountLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(splitBar.snp.bottom).offset(5)
            make.right.equalToSuperview()
        }
        
        let learningCountTextLabel: UILabel = {
            let label = UILabel()
            label.text = "Learning"
            label.font=v2Font(12)
            label.textColor = UIColor.gray
            return label
        }()
        rightContainer.addSubview(learningCountTextLabel);
        learningCountTextLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(notStartCountLabel.snp.bottom).offset(5)
            make.left.equalToSuperview()
        }
        rightContainer.addSubview(learningCountLabel);
        learningCountLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(notStartCountLabel.snp.bottom).offset(5)
            make.right.equalToSuperview()
        }
        
        let finishedCountTextLabel: UILabel = {
            let label = UILabel()
            label.text = "Finished"
            label.font=v2Font(12)
            label.textColor = UIColor.gray
            return label
        }()
        rightContainer.addSubview(finishedCountTextLabel);
        finishedCountTextLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(learningCountLabel.snp.bottom).offset(5)
            make.left.equalToSuperview()
        }
        rightContainer.addSubview(finishedCountLabel);
        finishedCountLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(learningCountLabel.snp.bottom).offset(5)
            make.right.equalToSuperview()
        }

        let bottomLine: UIView = {
           let v = UIView()
            v.backgroundColor = V2EXColor.colors.v2_backgroundColor
            return v
        }()
        self.contentView.addSubview(bottomLine);
        bottomLine.snp.makeConstraints{ (make) -> Void in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }

        self.backgroundColor=V2EXColor.colors.v2_CellWhiteBackgroundColor;
    }
    
    @objc func userNameTap(_ sender:UITapGestureRecognizer) {
//        if let _ = self.itemModel , let username = itemModel?.userName {
//            let memberViewController = MemberViewController()
//            memberViewController.username = username
//            V2Client.sharedInstance.centerNavigation?.pushViewController(memberViewController, animated: true)
//        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func superBind(_ model:UserWordStatModel){
        self.langNameLabel.text = Lang.fromId(id: model.lang)?.name;
        self.wordCountLabel.text = model.total_count>9999 ? "\(model.total_count)+" : String(model.total_count);
        self.avatarImageView.image = UIImage.getLangFlag(model.lang)
        self.todayNeedReviewCountLabel.text = model.needreview_count>99 ? "\(model.needreview_count)+" : String(model.needreview_count)
        self.notStartCountLabel.text = "\(model.notstart_count)"
        self.learningCountLabel.text = "\(model.learning_count)"
        self.finishedCountLabel.text = "\(model.finished_count)"
        
        if model.last_learn_time == nil{
            self.dateAndLastLearnedLabel.text = ""
        }
        else{
        self.dateAndLastLearnedLabel.text = model.last_learn_time!.toShortString()+" · "+String(model.last_learn_count!)
        }
        
        self.progressLabel.text = "\(model.finished_count) \(model.learning_count) \(model.notstart_count)"
        
        self.itemModel = model
    }
    
    func bind(_ model:UserWordStatModel){
        self.superBind(model)
//        self.dateAndLastPostUserLabel.text = model.date
//        self.nodeNameLabel.text = model.nodeName
    }
    
    func bindNodeModel(_ model:UserWordStatModel){
        self.superBind(model)
//        self.dateAndLastPostUserLabel.text = model.hits
//        self.nodeBackgroundImageView.isHidden = true
    }
    
    func getHeight(_ model:UserWordStatModel)->CGFloat{
        
        return 110
    }
}
