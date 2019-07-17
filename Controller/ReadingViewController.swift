//
//  UserBookViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit

import Alamofire
import AlamofireObjectMapper

import Ji
import MJRefresh

import SVProgressHUD


class ReadingViewController: UIViewController {
    override func viewDidLoad() {
//        self.navigationItem.title = "我的演讲"
        self.navigationController!.navigationBar.topItem?.title = "阅读"

//        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        rightButton.contentMode = .center
//        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
//        rightButton.setImage(UIImage.imageUsedTemplateMode("plus")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
//        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
}
