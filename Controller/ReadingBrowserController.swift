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
    
    var startLocation = CGPoint()
    var panDirection = 0
    
//    var popUpView: SearchPopUpView={
//        let pv = SearchPopUpView()
//
//        return pv
//    }()
    
    var webView: WKWebView = {
        let v = WKWebView()
        return v
    }()
    
    var addressView: UIView = {
        let v = UIView()
        return v
    }()
    
    var avOTrans=CGAffineTransform()
    var avHTrans=CGAffineTransform()
    var avShow=true
    
    lazy var addTxb: MyUITextField = {
        let txb = MyUITextField()
        txb.layer.cornerRadius = 5.0
        txb.layer.backgroundColor = #colorLiteral(red: 0.6146097716, green: 0.6146097716, blue: 0.6146097716, alpha: 1)
        txb.textColor = UIColor.white
        txb.tintColor = UIColor.white
        txb.returnKeyType = UIReturnKeyType.go
        
        txb.delegate = self
        
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
    
    var svOTrans=CGAffineTransform()
    var svHTrans=CGAffineTransform()
    var svShow=true
    
    let generalPasteboard = UIPasteboard.general
    
    lazy var saveAlertController:UIAlertController={
        let controller = UIAlertController(title: "书签信息", message: nil, preferredStyle: .alert)
        controller.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "请输入名称"
        })
        controller.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "请输入标题"
        })
        
        let okAction = UIAlertAction(title: "确定", style: .default) { (_) in
            
            let name = (controller.textFields![0] as UITextField).text
            let title = (controller.textFields![1] as UITextField).text
            
            var bookMark = self.initBookMark
            if bookMark == nil{
                bookMark = BookMarkModel()
                bookMark!.url = self.webView.url!.absoluteString
                bookMark!.name = name!
                bookMark!.title = title!
                self.delegate?.addBookMark(bookMark: bookMark!)
            }
            else{
                bookMark!.url = self.webView.url!.absoluteString
                bookMark!.name = name!
                bookMark!.title = title!
                bookMark!.time = Date()
                self.delegate?.editBookMark(bookMark: bookMark!)
            }
            
        }
        controller.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        return controller
    }()
    
    override func viewDidLoad() {
        
        self.view.addSubview(addressView)
        addressView.backgroundColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
        addressView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(40)
        }
        
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
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(panedView))
        self.view.addGestureRecognizer(panRecognizer)
        
        if let initUrl = self.initBookMark?.url{
            if !initUrl.isEmpty{
            addTxb.text = initUrl
            let url = URL(string: initUrl)!
            webView.load(URLRequest(url: url))
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let url_str = addTxb.text!
        if(!url_str.isEmpty)
        {
            addTxb.resignFirstResponder()
            let url = URL(string: url_str)
            webView.load(URLRequest(url: url!))
            return true
        }
        
        return false
    }
    
    // 在viewDidLoad中，获取不到view的frame尺寸!!!
    override func viewDidLayoutSubviews() {
        self.avOTrans = addressView.transform
        self.avHTrans = avOTrans.translatedBy(x: 0, y: -self.addressView.frame.height)
        
        self.svOTrans = statusView.transform
        self.svHTrans = svOTrans.translatedBy(x: 0, y: self.statusView.frame.height)
    }
    
    @objc func panedView(sender:UIPanGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizer.State.began) {
            startLocation = sender.location(in: self.view)
            self.panDirection = 0
        }
        else if(sender.state == UIGestureRecognizer.State.changed){            
        }
        else if (sender.state == UIGestureRecognizer.State.ended) {
            let currentLocation = sender.location(in: self.view)
            let dx = currentLocation.x - startLocation.x
            let dy = currentLocation.y - startLocation.y
            let distance = sqrt(dx * dx + dy * dy)
            if(distance>50){
                if(dx<0){
                    self.addressView.snp.removeConstraints()
                    addressView.snp.makeConstraints { (make) in
                        make.top.equalTo(self.view).offset(-40)
                        make.left.right.equalTo(self.view)
                        make.height.equalTo(40)
                    }
                    self.statusView.snp.removeConstraints()
                    statusView.snp.makeConstraints { (make) in
                        make.left.right.equalTo(self.view)
                        make.height.equalTo(50)
                        make.bottom.equalTo(self.view).offset(50)
                    }
                    
                    self.webView.snp.removeConstraints()
                    self.webView.snp.makeConstraints { (make) in
                        make.left.right.equalTo(self.view)
                        make.top.equalTo(self.addressView.snp.bottom)
                        make.bottom.equalTo(self.statusView.snp.top)}
                    
                    // 跟其他控件位置相关联的动画，必须这么做，不能只做目标控件的动画，然后去手动更改其他相关控件的位置!!!
                    // 否则会出现奇怪的现象
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }
                else{
                    self.addressView.snp.removeConstraints()
                    addressView.snp.makeConstraints { (make) in
                        make.left.top.right.equalTo(self.view)
                        make.height.equalTo(40)
                    }
                    self.statusView.snp.removeConstraints()
                    statusView.snp.makeConstraints { (make) in
                        make.left.bottom.right.equalTo(self.view)
                        make.height.equalTo(50)
                    }
                    
                    self.webView.snp.removeConstraints()
                    self.webView.snp.makeConstraints { (make) in
                        make.left.right.equalTo(self.view)
                        make.top.equalTo(self.addressView.snp.bottom)
                        make.bottom.equalTo(self.statusView.snp.top)}
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }
//            else{
//                if(avShow && panDirection<0){
//                    UIView.animate(withDuration: 0.3, animations: {
//                        self.addressView.transform = self.avOTrans
//                        self.statusView.transform = self.svOTrans
//                    })
//                }
//                else if(!avShow && panDirection>0){
//                    UIView.animate(withDuration: 0.3, animations: {
//                        self.addressView.transform = self.avHTrans
//                        self.statusView.transform = self.svHTrans
//                    })
//                }
//            }
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
            
            _ = DictionaryApi.provider
                .requestAPI(.searchWord(lang: 1, form: md))
                .mapResponseToObj(WordModel.self)
                .subscribe(onNext: { (response) in
                    
                    let popUpView = SearchPopUpView()
                    popUpView.setInfo(word: response)
                    let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    alertView.setValue(popUpView, forKey: "contentViewController")
                    
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertView, animated: true, completion: nil)
                    
                }, onError: { (error) in
                    SVProgressHUD.showError(withStatus: error.rawString())
                })
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
    
    @objc func browserBack(_ sneder:UIButton){
        webView.goBack()
    }
    func browserForward(_ sneder:UIButton){
        webView.goForward()
    }
    func browserRefresh(_ sneder:UIButton){
        webView.reload()
    }
    @objc func browserSave(_ sneder:UIButton){
        if let _ = webView.url?.absoluteString{
            if(self.initBookMark != nil){
                (saveAlertController.textFields![0] as UITextField).text = initBookMark!.name                
            }
            (saveAlertController.textFields![1] as UITextField).text = webView.title
            present(saveAlertController, animated: true, completion: nil)
        }
        else{
            SVProgressHUD.showError(withStatus: "请先加载网页！")
        }
    }    
}

class SearchPopUpView:UIViewController{
    
    var lbl_spell:UILabel={
        let lbl = UILabel()
        lbl.font = v2Font(25)
        return lbl
    }()
    
    var lbl_pronounce:UILabel={
        let lbl = UILabel()
        lbl.font = v2Font(14)
        return lbl
    }()
    
    var lbl_meaning:UILabel={
        let lbl = UILabel()
        lbl.font = v2Font(14)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    var scroll_view:UIScrollView={
        let v = UIScrollView()
        return v
    }()
    
    let v_width:CGFloat = 250
    
    
    override func viewDidLoad() {
        self.view.snp.makeConstraints { (make) in
            make.height.equalTo(150)
        }
        
        self.view.addSubview(scroll_view)
        scroll_view.snp.makeConstraints { (make) in
            make.width.equalTo(v_width)
            make.height.equalTo(150)
        }
        
        scroll_view.addSubview(lbl_spell)
        lbl_spell.snp.makeConstraints { (make) in
            make.left.top.equalTo(scroll_view).offset(10)
        }
        
        scroll_view.addSubview(lbl_pronounce)
        lbl_pronounce.snp.makeConstraints { (make) in
            make.left.equalTo(lbl_spell.snp.left)
            make.top.equalTo(lbl_spell.snp.bottom)
        }
        
        scroll_view.addSubview(lbl_meaning)
        lbl_meaning.snp.makeConstraints { (make) in
            make.left.equalTo(scroll_view).offset(10)
            make.top.equalTo(lbl_pronounce.snp.bottom).offset(5)
            make.width.equalTo(v_width-20)
        }
        
        // 不设置contentSize就不能滚动!!!
        let scroll_height = 10+lbl_spell.actualHeight(v_width)+lbl_pronounce.actualHeight(v_width)+5+lbl_meaning.actualHeight(v_width-20)+5
        scroll_view.contentSize = CGSize(width: v_width, height: scroll_height)
    }
    
    func setInfo(word:WordModel){
        lbl_spell.text = word.spell!
        lbl_pronounce.text = "[\(word.pronounce!)]"
        lbl_meaning.text = word.meaning!
    }
}
