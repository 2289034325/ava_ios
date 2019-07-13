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

class PublicBookListTableViewCell: UITableViewCell {
    //? 为什么用这个圆角图片，而不用layer.cornerRadius
    // 因为 设置 layer.cornerRadius 太耗系统资源，每次滑动 都需要渲染很多次，所以滑动掉帧
    // iOS中可以缓存渲染，但效果还是不如直接 用圆角图片

    /// 节点信息label的圆角背景图
//    fileprivate static var nodeBackgroundImage_Default =
//        createImageWithColor( V2EXDefaultColor.sharedInstance.v2_NodeBackgroundColor ,size: CGSize(width: 10, height: 20))
//            .roundedCornerImageWithCornerRadius(2)
//            .stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)
//    fileprivate static var nodeBackgroundImage_Dark =
//        createImageWithColor( V2EXDarkColor.sharedInstance.v2_NodeBackgroundColor ,size: CGSize(width: 10, height: 20))
//            .roundedCornerImageWithCornerRadius(2)
//            .stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)

    /// 语言国旗
    var avatarImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode=UIViewContentMode.scaleToFill
        return imageview
    }()

    /// 词书名
    var bookNameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
        return label;
    }()
    /// 用户数量
    var userCountLabel: YYLabel = {
        let label = YYLabel()
        label.font=v2Font(10)
        return label
    }()
    var userCountIconImageView: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "users"))
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    /// 单词数量
    var wordCountLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(12)
        return label
    }()
    var wordCountIconImageView: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "book"))
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    /// 描述
    var descriptionLabel: YYLabel = {
        let label = YYLabel()
        label.textVerticalAlignment = .top
        label.font=v2Font(18)
        label.displaysAsynchronously = true
        label.numberOfLines=0
//        label.preferredMaxLayoutWidth = SCREEN_WIDTH-24
        return label
    }()

    var descriptionLayout: YYTextLayout?

    /// 装上面定义的那些元素的容器
    var contentPanel:UIView = UIView()

    var itemModel:BookModel?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }

    func setup()->Void{
        let selectedBackgroundView = UIView()
        self.selectedBackgroundView = selectedBackgroundView

        self.contentView .addSubview(self.contentPanel);
        self.contentPanel.addSubview(self.bookNameLabel);
        self.contentPanel.addSubview(self.avatarImageView);
        self.contentPanel.addSubview(self.userCountLabel);
        self.contentPanel.addSubview(self.userCountIconImageView);
        self.contentPanel.addSubview(self.wordCountLabel);
        self.contentPanel.addSubview(self.wordCountIconImageView);
        self.contentPanel.addSubview(self.descriptionLabel);

        self.setupLayout()

        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        self.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
    }

    fileprivate func setupLayout(){
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        self.bookNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.userCountIconImageView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.width.height.equalTo(13);
            make.left.equalTo(self.bookNameLabel);
        }
        self.userCountLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.left.equalTo(self.userCountIconImageView.snp.right).offset(3);
        }
        self.wordCountLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.bookNameLabel);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.wordCountIconImageView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.wordCountLabel);
            make.width.height.equalTo(18);
            make.right.equalTo(self.wordCountLabel.snp.left).offset(-2);
        }
        self.descriptionLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
            make.bottom.equalTo(self.contentView).offset(-8)
        }
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-1);
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

    func superBind(_ model:BookModel){
        self.bookNameLabel.text = model.name;
        self.wordCountLabel.text = String(model.word_count);
        self.avatarImageView.image = UIImage.getLangFlag(model.lang)
        self.userCountLabel.text = String(model.user_count)
        self.descriptionLabel.text = model.description

        //计算描述label的高度
        let attributedString = NSMutableAttributedString(string: model.description,
                attributes: [
                    NSAttributedStringKey.font:v2Font(18)
                ])
        self.descriptionLayout = YYTextLayout(containerSize: CGSize(width: SCREEN_WIDTH-24, height: 9999), text: attributedString)


        self.itemModel = model
    }

    func bind(_ model:BookModel){
        self.superBind(model)
//        self.dateAndLastPostUserLabel.text = model.date
//        self.nodeNameLabel.text = model.nodeName
    }

    func bindNodeModel(_ model:BookModel){
        self.superBind(model)
//        self.dateAndLastPostUserLabel.text = model.hits
//        self.nodeBackgroundImageView.isHidden = true
    }
}
