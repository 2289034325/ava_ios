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
import MJRefresh
import SVProgressHUD
import WebKit
import MobileCoreServices


class PrivacyController: UIViewController,WKNavigationDelegate {
    override func viewDidLoad() {
        
        self.title = "用户服务协议"
        
        let webView = MyWKWebView()
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
        
        let url = URL(string: "https://au.acxca.com/privacy.html")
        webView.load(URLRequest(url: url!))
    }
}
