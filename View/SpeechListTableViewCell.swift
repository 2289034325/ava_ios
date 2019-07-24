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

class SpeechListTableViewCell: UITableViewCell {
    /// 语言国旗
    var avatarImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode=UIViewContentMode.scaleAspectFit
        return imageview
    }()

    /// 标题
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(14)
        return label;
    }()
    /// performer
    var performerLabel: YYLabel = {
        let label = YYLabel()
        label.font=v2Font(10)
        return label
    }()
    var performerImageView: UIImageView = {
        let imageview = UIImageView(image: UIImage(named: "users"))
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    /// 描述
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(18)
        label.numberOfLines=0
        return label
    }()

    var descriptionLayout: YYTextLayout?

    /// 装上面定义的那些元素的容器
    var contentPanel:UIView = UIView()

    var itemModel:PublicBookModel?

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
        self.contentPanel.addSubview(self.titleLabel);
        self.contentPanel.addSubview(self.performerLabel);
        self.contentPanel.addSubview(self.performerImageView);
        self.contentPanel.addSubview(self.avatarImageView);
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
        self.titleLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.performerImageView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.width.height.equalTo(13);
            make.left.equalTo(self.titleLabel);
        }
        self.performerLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.left.equalTo(self.performerImageView.snp.right).offset(3);
        }
        self.descriptionLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
        }
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-1);
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func bind(_ model:ArticleModel){
        self.avatarImageView.image = UIImage.getLangFlag(model.lang)
        self.titleLabel.text = model.title
        self.performerLabel.text = model.performer
        self.descriptionLabel.text = model.description
    }
    
    func getHeight(_ model:ArticleModel)->CGFloat{
        let descriptionHeight = self.descriptionLabel.actualHeight(SCREEN_WIDTH-24,model.description)
        
        return 12+35+12+descriptionHeight+12
    }
}
