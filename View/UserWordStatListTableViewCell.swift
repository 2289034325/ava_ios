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
        imageview.backgroundColor = UIColor.red
        imageview.contentMode=UIViewContentMode.scaleToFill
        return imageview
    }()
    
    /// 词书名
    var langNameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
        return label;
    }()
    /// 上次学习日期和数量
    var dateAndLastLearnedLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(12)
        return label
    }()
    /// 词书单词数量
    var wordCountLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
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
        label.font = v2Font(12)
        return label
    }()
    var todayNeedReviewCountImageView: UIImageView = {
        let img = UIImage(from: .segoeMDL2, code: "History", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        let imageview = UIImageView(image: img)
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    /// 已掌握，学习中，未学习
    var progressLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(18)
        label.numberOfLines=0
        return label
    }()
    
    var bottomLine: UIView = {
       let v = UIView()
        v.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return v
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
        
        self.contentView.addSubview(self.avatarImageView);
        self.contentView.addSubview(self.bottomLine);
        
        self.setupLayout()

        self.backgroundColor=V2EXColor.colors.v2_CellWhiteBackgroundColor;
    }
    
    fileprivate func setupLayout(){
        
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(5);
            make.height.equalTo(30);
            make.width.equalTo(40);
        }
        
        self.bottomLine.snp.makeConstraints { (make) in
            make.height.equalTo(0.5);
            make.left.equalTo(self.contentView).offset(10);
            make.right.bottom.equalTo(self.contentView);
        }
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
        self.langNameLabel.text = String(model.lang);
        self.wordCountLabel.text = model.total_count>9999 ? "\(model.total_count)+" : String(model.total_count);
        self.avatarImageView.image = UIImage.getLangFlag(model.lang)
        self.todayNeedReviewCountLabel.text = model.needreview_count>99 ? "\(model.needreview_count)+" : String(model.needreview_count)
        
        if model.last_learn_time == nil{
            self.dateAndLastLearnedLabel.text = ""
        }
        else{
        self.dateAndLastLearnedLabel.text = model.last_learn_time!.toRelativeString()+" · "+String(model.last_learn_count!)
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
        self.progressLabel.text = "\(model.finished_count) \(model.learning_count) \(model.notstart_count)"
        let descriptionHeight = self.progressLabel.actualHeight(SCREEN_WIDTH-24)
        
        return 12+35+12+descriptionHeight+12
    }
}
