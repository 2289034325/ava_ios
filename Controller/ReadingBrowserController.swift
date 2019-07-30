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

//class MyWebView : WKWebView {
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return false
//    }
//}

class ReadingBrowserController: UIViewController,WKNavigationDelegate,UITextFieldDelegate {
    
    var webView: WKWebView = {
        let v = WKWebView()
        return v
    }()
    
    var addressView: UIView = {
        let v = UIView()
        return v
    }()
    
    var addTxb: MyUITextField = {
        let txb = MyUITextField()
        return txb
    }()
    
    var addCancelBtn: UIButton = {
        let btn = UIButton()
//        btn.titleLabel?.text = "取消"
        btn.setTitle("取消", for: UIControlState())
        
        return btn
    }()
    
    var statusView: UIView = {
        let v = UIView()
        return v
    }()
    
    let generalPasteboard = UIPasteboard.general
    
    override func viewDidLoad() {
        
        self.view.addSubview(addressView)
        addressView.backgroundColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
        addressView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(40)
        }
        
        addTxb.layer.cornerRadius = 5.0
        addTxb.layer.backgroundColor = #colorLiteral(red: 0.6146097716, green: 0.6146097716, blue: 0.6146097716, alpha: 1)
        addTxb.textColor = UIColor.white
        addTxb.tintColor = UIColor.white
        addTxb.delegate = self
        addressView.addSubview(addTxb)
        addTxb.snp.makeConstraints { (make) in
            make.left.top.equalTo(addressView).offset(5)
            make.bottom.right.equalTo(addressView).offset(-5)
        }
        
        addressView.addSubview(addCancelBtn)
        addCancelBtn.addTarget(self, action: #selector(ReadingBrowserController.addCancelClick(_:)), for: .touchUpInside)
        addCancelBtn.snp.makeConstraints { (make) in
            make.top.equalTo(addressView).offset(5)
            make.bottom.equalTo(addressView).offset(-5)
            make.left.equalTo(addTxb.snp.right).offset(10)
        }
        
        self.view.addSubview(statusView)
        statusView.layer.backgroundColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
        statusView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self.view)
            make.height.equalTo(50)
        }
        
        
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(addressView.snp.bottom)
            make.bottom.equalTo(statusView.snp.top)
        }
        
//        setupCustomMenu()

        NotificationCenter.default.addObserver(self, selector: #selector(pasteboardChanged(_:)), name: NSNotification.Name.UIPasteboardChanged, object: generalPasteboard)
        
        let url = URL(string: "https://www.economist.com/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addTxb.snp.removeConstraints()
        addTxb.snp.makeConstraints { (make) in
            make.left.top.equalTo(addressView).offset(5)
            make.bottom.equalTo(addressView).offset(-5)
            make.right.equalTo(addressView).offset(-60)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        addTxb.snp.removeConstraints()
        addTxb.snp.makeConstraints { (make) in
            make.left.top.equalTo(addressView).offset(5)
            make.bottom.equalTo(addressView).offset(-5)
            make.right.equalTo(addressView).offset(-5)
        }
    }
    
    func addCancelClick(_ sneder:UIButton){
//        addTxb.snp.removeConstraints()
//        addTxb.snp.makeConstraints { (make) in
//            make.left.top.equalTo(addressView).offset(5)
//            make.bottom.equalTo(addressView).offset(-5)
//            make.right.equalTo(addressView).offset(-5)
//        }
        
        addTxb.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(NSNotification.Name.UIPasteboardChanged)
        super.viewDidDisappear(animated)
    }
    
    @objc
    func pasteboardChanged(_ notification: Notification) {
        if let md = UIPasteboard.general.string{
            let alertView = UIAlertController(title: "Yay!!", message: md, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "cool", style: .default, handler: nil))
            present(alertView, animated: true, completion: nil)
        }
    }
    
    func setupCustomMenu() {
        let customMenuItem = UIMenuItem(title: "Foo", action:
            #selector(ReadingBrowserController.transelateMenuTapped))
        UIMenuController.shared.menuItems = [customMenuItem]
        UIMenuController.shared.update()
    }
    
    @objc func transelateMenuTapped() {
        let yay = "" //Need to retrieve the selected text here
        let alertView = UIAlertController(title: "Yay!!", message: yay, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "cool", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
}
