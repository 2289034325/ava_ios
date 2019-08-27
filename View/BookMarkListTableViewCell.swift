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

class BookMarkListTableViewCell: UITableViewCell {
    
    var placeholder_img:UIImage = {
        let img = UIImage(named: "ic_turned_in")!
        
        return img
    }()
    
    /// favicon
    var avatarImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode=UIViewContentMode.scaleAspectFit
        
        return imageview
    }()

    /// 标题
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = v2Font(20)
        return label;
    }()

    /// 描述
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font=v2Font(13)
        label.numberOfLines=0
        return label
    }()

    var descriptionLayout: YYTextLayout?

    /// 装上面定义的那些元素的容器
    var contentPanel:UIView = UIView()

    var itemModel:BookMarkModel?

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
        self.contentPanel.addSubview(self.nameLabel);
        self.contentPanel.addSubview(self.titleLabel);
        self.contentPanel.addSubview(self.avatarImageView);

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
            make.height.width.equalTo(40)
        }
        self.nameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.titleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom);
            make.left.equalTo(self.nameLabel);
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

    func bind(_ model:BookMarkModel){
        self.nameLabel.text = model.name
        self.titleLabel.text = model.title
        
        if(!model.url.isEmpty) {
            let url = URL(string: model.url)!
            let url_str = "\(url.scheme!)://\(url.host!)\(url.port == nil ? "" : ":"+String(url.port!))/favicon.ico"
            self.avatarImageView.fin_setImageWithUrl(URL(string: url_str)!, placeholderImage: placeholder_img, imageModificationClosure: fin_defaultImageModification())
        }
    }
    
    func getHeight(_ model:BookMarkModel)->CGFloat{
        self.titleLabel.text = model.title
        let titleHeight = self.titleLabel.actualHeight(SCREEN_WIDTH-24)
        
        return 12+40+titleHeight+12
    }
}
