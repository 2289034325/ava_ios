//
//  ArticleController2.swift
//  Speech
//
//  Created by 菜白 on 2018/8/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import AVKit

import SnapKit

import Alamofire
import AlamofireObjectMapper

import MJRefresh

import SVProgressHUD

class SpeechController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    
    //    func expandMenu(expand: Bool) {
    //        if(expand){
    ////            constraintsOfRecordMenu[4].constant = 40
    //            recrdMenuView.snp.removeConstraints()
    //            recrdMenuView.snp.makeConstraints{ (make) -> Void in
    //                make.bottom.left.right.equalTo(self.view)
    //                make.height.equalTo(40)
    //            }
    //            recrdMenuView.collectionView.collectionViewLayout.invalidateLayout()
    //        }
    //        else{
    ////            constraintsOfRecordMenu[4].constant = 0
    //            recrdMenuView.snp.removeConstraints()
    //            recrdMenuView.snp.makeConstraints{ (make) -> Void in
    //                make.bottom.left.right.equalTo(self.view)
    //                make.height.equalTo(0)
    //            }
    //            recrdMenuView.collectionView.collectionViewLayout.invalidateLayout()
    //        }
    //    }
    
    var article: ArticleModel?
    
    var vController: AVPlayerViewController?
    
    var timeObserver: Any?
    
    
    let generalPasteboard = UIPasteboard.general
    
    var player: AVPlayer?{
        didSet{
            vController?.player = self.player
        }
    }
    
    let mediaView = UIView()
    let tableView = UITableView()
    let recrdMenuView = RecordMenuView()
    //    let playerMenuView = PlayerMenuView()
    
    //    var constraintsOfRecordMenu:[NSLayoutConstraint] = []
    
    // 实例化UIMenuController会crash!!!
    //    var selMenu: UIMenuController = {
    //       let mn = UIMenuController()
    //        let mi_ava = UIMenuItem(title:"AVA", action:#selector(searchAVA))
    //        let mi_ggl = UIMenuItem(title:"Google", action:#selector(searchGGL))
    //        mn.menuItems = [mi_ava,mi_ggl]
    //
    //        return mn
    //    }()
    
    func setupCustomMenu() {
        let mi_ava = UIMenuItem(title:"AVA", action:#selector(searchAVA))
        let mi_ggl = UIMenuItem(title:"Google", action:#selector(searchGGL))
        UIMenuController.shared.menuItems = [mi_ava,mi_ggl]
        UIMenuController.shared.update()
    }
    
    @objc func searchAVA(_ sender:Any?){
        let md = selectionText!
        _ = DictionaryApi.provider
            .requestAPI(.searchWord(lang: article!.lang, form: md))
            .mapResponseToObj(WordSearchModel.self)
            .subscribe(onNext: { (response) in
                
                let popUpView = SearchPopUpView()
                popUpView.setInfo(word: response.word!)
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alertView.setValue(popUpView, forKey: "contentViewController")
                
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertView, animated: true, completion: nil)
                
            }, onError: { (error) in
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    @objc func searchGGL(_ sender:Any?){
        let md = selectionText!       
        
        _ = OtherApi.provider
            .requestAPI(.googleTranslate(text: md))
            .mapResponseToObj(GoogleTransModel.self)
            .subscribe(onNext: { (response) in
                
                let popUpView = SearchPopUpView()
                let text = response.getAllTrans()                
                popUpView.setInfo(trans: text)
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alertView.setValue(popUpView, forKey: "contentViewController")
                
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertView, animated: true, completion: nil)
                
            }, onError: { (error) in
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    var selectionText:String?
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if (textView.selectedTextRange != nil){
            self.selectionText = textView.text(in:textView.selectedTextRange!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(pasteboardChanged(_:)), name: NSNotification.Name.UIPasteboardChanged, object: generalPasteboard)
        
        setSubviews()
        
        loadArticle()
        
        setNavigationBar()
        
        setupCustomMenu()
        
        // 设置后台播放
        do{
            // 不加这些，项目属性设置UIBackgroundModes没有用!!!
            let ss = AVAudioSession.sharedInstance()
            try ss.setCategory(AVAudioSessionCategoryPlayback)
            try ss.setActive(true)
        } catch {
            print(error)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func setSubviews(){
        
        tableView.dataSource = self
        tableView.delegate = self
        //        playerMenuView.delegate = self
        
        self.edgesForExtendedLayout = []
        
        self.view.addSubview(mediaView)
        self.view.addSubview(tableView)
        //        self.view.addSubview(playerMenuView)
        self.view.addSubview(recrdMenuView)
        
        mediaView.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.view)
            // 200 full view. 45 only show playback controls
            if(self.playerVisible){
                make.height.equalTo(200)
            }
            else{
                make.height.equalTo(45)
            }
        }
        recrdMenuView.snp.makeConstraints{ (make) -> Void in
            make.bottom.left.right.equalTo(self.view)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(mediaView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(recrdMenuView.snp.top)
        }
        
        vController = AVPlayerViewController()
        vController!.view.frame = self.mediaView.bounds
        self.addChildViewController(vController!)
        self.mediaView.addSubview(vController!.view)
        vController!.didMove(toParentViewController: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.article!.paragraphs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.article!.paragraphs[section].splits.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let hv = UIView()
        hv.backgroundColor = V2EXColor.colors.v2_backgroundColor;
        let htl = UILabel()
        htl.font = UIFont.boldSystemFont(ofSize: 17)
        htl.numberOfLines = 0
        htl.lineBreakMode = .byCharWrapping
        htl.text = self.article!.paragraphs[section].performer+":"
        hv.addSubview(htl)
        htl.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(hv)
            make.left.equalTo(hv).offset(5)
            make.right.equalTo(hv).offset(-5)
        }
        
        let splitDbTap = UITapGestureRecognizer(target: self, action: #selector(SpeechController.headerDbTapAction))
        splitDbTap.numberOfTapsRequired = 2
        
        hv.isUserInteractionEnabled = true
        hv.addGestureRecognizer(splitDbTap)
        
        hv.accessibilityElements = [self.article!.paragraphs[section]]
        
        return hv
    }
    
    //    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //
    //        return 100.0 // You can set any other value, it's up to you
    //    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        let paragraph = self.article!.paragraphs[indexPath.section]
        //        let split = paragraph.splits[indexPath.row]
        //        let startIndex = paragraph.text.index(paragraph.text.startIndex, offsetBy: split.start_index)
        //        let endIndex =  paragraph.text.index(paragraph.text.startIndex, offsetBy: split.end_index+1)
        //        let text = String(paragraph.text[startIndex ..< endIndex])
        
        //        let htl = UILabel()
        //        htl.font = v2Font(18)
        //        htl.numberOfLines = 0
        //        htl.lineBreakMode = .byWordWrapping
        //        htl.text =  "  "+text
        //        return htl.actualHeight(SCREEN_WIDH-10)+10
        
        // 自动适配高度!!!
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell()
        
        let paragraph = self.article!.paragraphs[indexPath.section]
        let split = paragraph.splits[indexPath.row]
        
        //        let label = UILabel()
        //        label.font = v2Font(18)
        //        label.numberOfLines = 0
        //        label.lineBreakMode = .byWordWrapping
        //        let startIndex = paragraph.text.index(paragraph.text.startIndex, offsetBy: split.start_index)
        //        let endIndex =  paragraph.text.index(paragraph.text.startIndex, offsetBy: split.end_index+1)
        //        label.text = "  "+String(paragraph.text[startIndex ..< endIndex])
        //
        //        let splitDbTap = UITapGestureRecognizer(target: self, action: #selector(SpeechController.splitDbTapAction))
        //        splitDbTap.numberOfTapsRequired = 2
        //
        //        label.isUserInteractionEnabled = true
        //        label.addGestureRecognizer(splitDbTap)
        //
        //        label.accessibilityElements = [split]
        //
        //        cell.contentView.addSubview(label)
        //        label.snp.makeConstraints{ (make) -> Void in
        //            make.top.equalTo(cell.contentView).offset(5)
        //            make.left.equalTo(cell.contentView).offset(5)
        //            make.right.equalTo(cell.contentView).offset(-5)
        //        }
        
        let textView = MyTextView()
        textView.isEditable = false
        // 不加isScrollEnabled，文字不显示!!!
        textView.isScrollEnabled = false
        textView.font = v2Font(18)
        textView.textContainer.lineBreakMode = .byWordWrapping
        let startIndex = paragraph.text.index(paragraph.text.startIndex, offsetBy: split.start_index)
        let endIndex =  paragraph.text.index(paragraph.text.startIndex, offsetBy: split.end_index+1)
        textView.text = "  "+String(paragraph.text[startIndex ..< endIndex])
        
        let splitDbTap = UITapGestureRecognizer(target: self, action: #selector(SpeechController.splitDbTapAction))
        splitDbTap.numberOfTapsRequired = 2
        
        textView.isUserInteractionEnabled = true
        textView.addGestureRecognizer(splitDbTap)
        
        textView.accessibilityElements = [split]
        
        cell.contentView.addSubview(textView)
        textView.snp.makeConstraints{ (make) -> Void in
            // top 和 bottom约束必须都有，否则textView不能等自动适配高度!!!
            make.top.bottom.equalTo(cell.contentView)
            make.left.equalTo(cell.contentView).offset(5)
            make.right.equalTo(cell.contentView).offset(-5)
        }
        
        textView.delegate = self
        
        return cell
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        NotificationCenter.default.removeObserver(NSNotification.Name.UIPasteboardChanged)
    //        super.viewDidDisappear(animated)
    //    }
    
    //    @objc func pasteboardChanged(_ notification: Notification) {
    //        if let md = UIPasteboard.general.string{
    //
    //            _ = DictionaryApi.provider
    //                .requestAPI(.searchWord(lang: 1, form: md))
    //                .mapResponseToObj(WordModel.self)
    //                .subscribe(onNext: { (response) in
    //
    //                    let popUpView = SearchPopUpView()
    //                    popUpView.setInfo(word: response)
    //                    let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    //                    alertView.setValue(popUpView, forKey: "contentViewController")
    //
    //                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //                    self.present(alertView, animated: true, completion: nil)
    //
    //                }, onError: { (error) in
    //                    SVProgressHUD.showError(withStatus: error.rawString())
    //                })
    //        }
    //    }
    
    @objc func headerDbTapAction(sender:UITapGestureRecognizer) {
        
        let header = sender.view!
        let paragraph = header.accessibilityElements![0] as! ParagraphModel
        let first_split = paragraph.splits.first!
        let last_split = paragraph.splits.last!
        
        let time = CMTimeMakeWithSeconds(Double(first_split.start_time), 10000)
        self.player!.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.player!.play()
        
        if let timeObserver = timeObserver {
            player!.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        let times = [NSValue(time: CMTimeMakeWithSeconds(TimeInterval(last_split.end_time), 10000))]
        timeObserver = self.player?.addBoundaryTimeObserver(forTimes: times, queue: DispatchQueue.main, using: {
            self.player?.pause()
            
            self.player!.removeTimeObserver(self.timeObserver!)
            self.timeObserver = nil
        })
    }
    
    @objc func splitDbTapAction(sender:UITapGestureRecognizer) {
        
        let lbl = sender.view as! UITextView
        let split = lbl.accessibilityElements![0] as! ParagraphSplitModel
        
        let time = CMTimeMakeWithSeconds(Double(split.start_time), 10000)
        self.player!.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.player!.play()
        
        if let timeObserver = timeObserver {
            player!.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        let times = [NSValue(time: CMTimeMakeWithSeconds(TimeInterval(split.end_time), 10000))]
        timeObserver = self.player?.addBoundaryTimeObserver(forTimes: times, queue: DispatchQueue.main, using: {
            self.player?.pause()
            
            self.player!.removeTimeObserver(self.timeObserver!)
            self.timeObserver = nil
        })
    }
    
    func setNavigationBar(){
        navigationItem.hidesBackButton=false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.player?.pause()
        self.recrdMenuView.stopPlayingAndRecording()
    }
    
    func loadArticle()
    {
        _ = SpeechApi.provider
            .requestAPI(.getArticle(article_id: self.article!.id))
            .mapResponseToObj(ArticleModel.self)
            .subscribe(onNext: { (response) in
                self.article = response
                self.tableView.reloadData()
                
                //                self.playerMenuView.playCell?.end_time = self.article!.paragraphs[0].splits[0].end_time
                //                self.playerMenuView.playCell?.loadMedia(media_url: self.article!.media_url, media_name: self.article!.media_name)
                
                
                self.loadMedia()
                
            }, onError: { (error) in
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    // 有时候服务端会重新上传视频，这里就需要强制重新下载
    func reloadMedia(){
        let medias = self.article!.medias.filter { (model) -> Bool in
        return model.usage == MediaUsages.ORIGIN.value
        }
        
        if(medias.count > 0)
        {
            let media = medias[0]
            
            let url = URL(string:media.getDownloadUrl())
            Downloader.loadFileAsync(url: url!, fileName: media.name, overWrite: true, completion: {filePath,error in self.initMedia(filePath!) })
        }
    }
    
    func loadMedia(){
        let medias = self.article!.medias.filter { (model) -> Bool in
        return model.usage == MediaUsages.ORIGIN.value
        }
        
        if(medias.count > 0)
        {
            let media = medias[0]
            
            let fileManager = FileManager.default
            var paths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
            
            let mediafilePath = paths[0].appending("/\(media.name)")
            if !fileManager.fileExists(atPath: mediafilePath)
            {
                let url = URL(string:media.getDownloadUrl())
                Downloader.loadFileAsync(url: url!, fileName: media.name, overWrite: false, completion: {filePath,error in self.initMedia(filePath!) })
            }
            else{
                initMedia(mediafilePath)
            }
        }
    }
    
    func initMedia(_ mediafilePath:String){
        //        do {
        //            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //        } catch _ {}
        
        do {
            let videoURL = URL(fileURLWithPath: mediafilePath)
            //            vController.player = AVPlayer(url: videoURL!)
            let item = AVPlayerItem(url: videoURL)
            
            if self.player == nil {
                self.player = AVPlayer(playerItem: item)
                //                var times = [NSValue]()
                //                self.article?.paragraphs.forEach({ paragraph in
                //                    var tms = [NSValue]()
                //                    paragraph.splits.forEach({ (split) in
                //                        print(split.start_time,split.end_time)
                //                        let t = CMTimeMakeWithSeconds(TimeInterval(split.end_time), 1000000000)
                //                        tms.append(NSValue(time:t))
                //                        print(NSValue(time:t))
                //                    })
                //                    times.append(contentsOf: tms)
                //                })
                
            } else {
                throw "player has already been initialized"
            }
            
            //            let playerLayer = AVPlayerLayer.init(player: self.player)
            //            playerLayer.videoGravity = .resizeAspect
            //            playerLayer.frame = self.mediaView.bounds
            //            self.mediaView.layer.addSublayer(playerLayer)
            
            //            self.playerMenuView.playCell?.player = vController!.player
            
            //            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audiofilePath))
            //            player!.prepareToPlay()
            
            //            self.player?.play()
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    //    func downloadMedia(_ downloadUrl:URL,_ fileName:String){
    //        Downloader.loadFileAsync(url: downloadUrl, fileName: fileName, completion: {filePath,error in self.initMedia(filePath!) })
    //    }
    
    lazy var menuController: UIAlertController = {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let names = self.playerVisible ? ["缩小播放器","重新下载音频"] : ["放大播放器","重新下载音频"]
        for name in names {
            let action = UIAlertAction(title: name, style: .default) { (action) in
                
                let title = action.title!
                
                if title == "缩小播放器" {
                    self.playerVisible = false
                }
                else if title == "放大播放器"{
                    self.playerVisible = true
                }
                else{
                    self.reloadMedia()
                }
            }
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        return controller
    }()
    
    var playerVisible : Bool {
        
        didSet{
            if(playerVisible){
                
                mediaView.snp.removeConstraints()
                mediaView.snp.makeConstraints{ (make) -> Void in
                    make.top.left.right.equalTo(self.view)
                    // 200 full view. 45 only show playback controls
                    make.height.equalTo(200)
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
                
                menuController.actions[0].setValue("缩小播放器", forKey: "title")
                
            }
            else{
                
                mediaView.snp.removeConstraints()
                mediaView.snp.makeConstraints{ (make) -> Void in
                    make.top.left.right.equalTo(self.view)
                    // 200 full view. 45 only show playback controls
                    // 如果这里完全隐藏，设置为0的话，下次播放器再显示出来的时候播放控制按钮会显示异常，需要全屏放大后再缩回来才会回复正常!!!
                    make.height.equalTo(45)
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
                
                menuController.actions[0].setValue("放大播放器", forKey: "title")
            }
        }
    }
    
    // controller init 垃圾东西!!!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.playerVisible = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func expandMenu(){
        present(menuController, animated: true, completion: nil)
    }
}
