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

class WritingListTableViewCell: UITableViewCell {
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
    /// source
    var sourceLabel: YYLabel = {
        let label = YYLabel()
        label.font=v2Font(10)
        return label
    }()
    var sourceImageView: UIImageView = {
        let img = UIImage(from: .segoeMDL2, code: "InternetSharing", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        let imageview = UIImageView(image: img)
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    /// 时间
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(10)
        label.numberOfLines=0
        return label
    }()
    var timeImageView: UIImageView = {
        let img = UIImage(from: .segoeMDL2, code: "Recent", textColor: .gray, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        let imageview = UIImageView(image: img)
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
    
    // 分割线
    let bottomLine: UIView = {
       let v = UIView()
        v.backgroundColor = V2EXColor.colors.v2_backgroundColor
        return v
    }()


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
        
        self.contentView.addSubview(self.avatarImageView);
        self.contentView.addSubview(self.titleLabel);
        self.contentView.addSubview(self.sourceLabel);
        self.contentView.addSubview(self.sourceImageView);
        self.contentView.addSubview(self.timeLabel);
        self.contentView.addSubview(self.timeImageView);
        self.contentView.addSubview(self.descriptionLabel);
        self.contentView.addSubview(self.bottomLine);
        
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(5);
            make.width.equalTo(40);
            make.height.equalTo(30);
        }
        self.titleLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(5);
            make.top.equalTo(self.avatarImageView);
            make.right.equalToSuperview().offset(-5)
        }
        self.sourceImageView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.width.height.equalTo(13);
            make.left.equalTo(self.titleLabel);
        }
        self.sourceLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.sourceImageView);
            make.left.equalTo(self.sourceImageView.snp.right).offset(3);
        }
        self.timeImageView.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.width.height.equalTo(13);
            make.left.equalTo(self.sourceLabel.snp.right).offset(5);
        }
        self.timeLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.timeImageView);
            make.left.equalTo(self.timeImageView.snp.right).offset(3);
        }
        self.descriptionLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentView).offset(-5);
        }
        self.bottomLine.snp.makeConstraints{ (make) -> Void in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.backgroundColor=V2EXColor.colors.v2_CellWhiteBackgroundColor;
//        self.backgroundColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // 其他Contrtoller不加这个设置就可以，这里不加的话，颜色显示异常!!!
        // TODO
        if(selected)
        {
            self.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
        else{
            self.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        }
    }

    func bind(_ model:WritingArticleModel){
        self.avatarImageView.image = UIImage.getLangFlag(model.lang)
        self.titleLabel.text = model.title
        self.sourceLabel.text = model.source
        self.timeLabel.text = model.insert_time!.toFullString()
        self.descriptionLabel.text = model.description
    }
    
    func getHeight(_ model:WritingArticleModel)->CGFloat{
        self.descriptionLabel.text = model.description
        let descriptionHeight = self.descriptionLabel.actualHeight(SCREEN_WIDTH-10)
        
        return 5+30+12+descriptionHeight+5
    }
}
