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

protocol SaveBookMarkDelegate
{
    func editBookMark(bookMark:BookMarkModel)
    func addBookMark(bookMark:BookMarkModel)
}

class ReadingBrowserController: UIViewController,WKNavigationDelegate,UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    var initBookMark:BookMarkModel?
    
    var delegate: SaveBookMarkDelegate?
    
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
    
//    var statusViewContainer: UIView = {
//        let c = UIView()
//        return c
//    }()
    
    lazy var statusView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        
        return cv
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
        
//        statusView.layer.backgroundColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
//        statusViewContainer.addSubview(statusView)
//        statusView.snp.removeConstraints()
//        statusView.snp.makeConstraints { (make) in
//            make.height.equalTo(50)
//        }
        
        //即使是UICollectionViewCell，也必须注册，不注册就会出异常!!!
        statusView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        statusView.backgroundColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
        self.view.addSubview(statusView)
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
        
        if let initUrl = self.initBookMark?.url{
            if !initUrl.isEmpty{
            addTxb.text = initUrl
            let url = URL(string: initUrl)!
            webView.load(URLRequest(url: url))
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.width/4,height:collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if indexPath.row == 0 {
            let btn = UIButton()
            btn.tintColor = .white
            let img = UIImage(from: .segoeMDL2, code: "ChevronLeft", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
            btn.setImage(img.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
            
            btn.addTarget(self, action: #selector(ReadingBrowserController.browserBack(_:)), for: .touchUpInside)

            cell.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.left.top.right.bottom.equalTo(cell)
            }
        }
        else if indexPath.row == 1 {
            let btn = UIButton()
            btn.tintColor = .white
            let img = UIImage(from: .segoeMDL2, code: "ChevronRight", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
            btn.setImage(img.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
            
            btn.addTarget(self, action: #selector(ReadingBrowserController.browserForward(_:)), for: .touchUpInside)

            cell.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.left.top.right.bottom.equalTo(cell)
            }
        }
        else if indexPath.row == 2 {
            let btn = UIButton()
            btn.tintColor = .white
            let img = UIImage(from: .segoeMDL2, code: "Sync", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
            btn.setImage(img.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)

            btn.addTarget(self, action: #selector(ReadingBrowserController.browserRefresh(_:)), for: .touchUpInside)
            
            cell.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.left.top.right.bottom.equalTo(cell)
            }
        }
        else if indexPath.row == 3 {
            let btn = UIButton()
            btn.tintColor = .white
            let img = UIImage(from: .segoeMDL2, code: "Pinned", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
            btn.setImage(img.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)

            btn.addTarget(self, action: #selector(ReadingBrowserController.browserSave(_:)), for: .touchUpInside)
            
            cell.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.left.top.right.bottom.equalTo(cell)
            }
        }
        
        return cell
    }
    
    func browserBack(_ sneder:UIButton){
        webView.goBack()
    }
    func browserForward(_ sneder:UIButton){
        webView.goForward()
    }
    func browserRefresh(_ sneder:UIButton){
        webView.reload()
    }
    func browserSave(_ sneder:UIButton){
        if let url = webView.url?.absoluteString{
            var bookMark = initBookMark
            if bookMark == nil{
                bookMark = BookMarkModel()
                bookMark!.url = url
                delegate?.addBookMark(bookMark: bookMark!)
            }
            else{
                bookMark!.url = url
                delegate?.editBookMark(bookMark: bookMark!)
            }
        }
    }    
}