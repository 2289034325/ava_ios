//
//  LoginViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import OnePasswordExtension
import Kingfisher
import SVProgressHUD
import Alamofire
import ObjectMapper
import SnapKit



class WordViewController: UIViewController {
    var word:WordModel?
    var index:Int?

    fileprivate lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        regClass(tableView, cell: WordSentenceTableViewCell.self)
        regClass(tableView, cell: WordTitleTableViewCell.self)

        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化界面
//        self.setupView()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
    }
}

extension WordViewController: UITableViewDelegate,UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return word!.explains!.count+1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        return word!.explains![section].sentences!.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 50
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section != 0) {
            let cell = getCell(tableView, cell: WordSentenceTableViewCell.self, indexPath: indexPath);
            let expl = word!.explains![indexPath.section]
            let stc = expl.sentences![indexPath.row]
            cell.setContent(stc)
            return cell;
        }
        else{
            let cell = getCell(tableView, cell: WordTitleTableViewCell.self, indexPath: indexPath);
            cell.setContent(word!)
            return cell;
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return ""
        }

        return word!.explains![section].explain!
    }
}



extension WordViewController {

    func setupView(){
        // 用UIView，上方会被navigationbar挡住
        // 因为UIView似乎是从屏幕左上方开始布局，不管是否有navigationbar
        // UIScrollView是自动从navigationbar的下面开始
        let contentView = UIScrollView()
        self.view.addSubview(contentView);
        contentView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }

        let spellLabel = UILabel()
        spellLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)!;
        spellLabel.text = word!.spell
        contentView.addSubview(spellLabel);
        spellLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(5)
        }

        let pronLabel = UILabel()
        pronLabel.text = "[\(word!.pronounce!)]"
        pronLabel.font = v2Font(12)
        contentView.addSubview(pronLabel);
        pronLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(spellLabel.snp.bottom)
            make.left.equalTo(spellLabel.snp.left)
        }

        var pronImage: UIImageView = {
            let imageview = UIImageView(image: UIImage(named: "sound")?.withRenderingMode(.alwaysTemplate))
            imageview.tintColor = UIColor.blue
            imageview.contentMode = .scaleAspectFit

            return imageview
        }()
        contentView.addSubview(pronImage);
        pronImage.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(pronLabel);
            make.width.height.equalTo(12);
            make.left.equalTo(pronLabel.snp.right).offset(2);
        }

        let meaningLabel = UILabel()
        meaningLabel.numberOfLines = 0
        meaningLabel.text = word!.meaning!
        meaningLabel.font = v2Font(12)
        contentView.addSubview(meaningLabel);
        meaningLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(pronLabel.snp.bottom).offset(5)
            make.left.equalTo(pronLabel.snp.left)
        }
    }
}
