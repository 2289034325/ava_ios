//
//  MenuView.swift
//  Speech
//
//  Created by 菜白 on 2018/8/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import AVFoundation

protocol MenuExpandDelegate {
    
    func expandMenu(expand:Bool)
}

class PlayerMenuView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    var delegate:MenuExpandDelegate?
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    var abCell:ABCell?
    var playCell:PlayCell?
    var stopCell:StopCell?
    var timeCell:TimeCell?
    var expandCell:ExpandCell?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        
        collectionView.register(ABCell.self, forCellWithReuseIdentifier: "abcell")
        collectionView.register(PlayCell.self, forCellWithReuseIdentifier: "playcell")
        collectionView.register(StopCell.self, forCellWithReuseIdentifier: "stopcell")
        collectionView.register(TimeCell.self, forCellWithReuseIdentifier: "timecell")
        collectionView.register(ExpandCell.self, forCellWithReuseIdentifier: "expandcell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        collectionView.allowsMultipleSelection = true
        
        addSubview(collectionView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":collectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":collectionView]))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:frame.width/5,height:frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if(indexPath.row == 0){
            //ab
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "abcell", for: indexPath)
            abCell = cell as? ABCell
        }
        else if(indexPath.row == 1){
            //播放，暂停
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playcell", for: indexPath)
            playCell = cell as? PlayCell
            abCell?.playCell = playCell
        }
        else if (indexPath.row == 2){
            //停止
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stopcell", for: indexPath)
            stopCell = cell as? StopCell
            stopCell?.playCell = playCell
            stopCell?.abCell = abCell
        }
        else if(indexPath.row == 3){
            //音频时长
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timecell", for: indexPath)
            timeCell = cell as? TimeCell
            playCell?.timeCell = timeCell
        }
        else if(indexPath.row == 4){
            //显示录音控制
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expandcell", for: indexPath)
            expandCell = cell as? ExpandCell
            expandCell?.parent = self
        }
        
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class TimeCell:UICollectionViewCell{
        let textView:UITextView={
            let tv = UITextView()
            tv.translatesAutoresizingMaskIntoConstraints = false
            
            tv.text = "00:00:00"+"\n"+"00:00:00"
            tv.tintColor = UIColor.gray
            tv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            tv.isEditable = false
            tv.textContainerInset = UIEdgeInsets(top: 2 , left: 20, bottom: 0, right: 0)
            tv.textContainer.lineFragmentPadding = 0
            
            return tv
        }()
        
        override init(frame:CGRect){
            super.init(frame:frame)
            
            addSubview(textView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(100)]", options: [], metrics: nil, views: ["v0":textView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":textView]))
            
            addConstraint(NSLayoutConstraint(item: textView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    class PlayCell:UICollectionViewCell,AVAudioPlayerDelegate{
        
//        private var player:AVAudioPlayer?
        
        var player:AVPlayer?
        
        //time bound of split
        var start_time:Float = 0
        var end_time:Float = 0
        
        //ab play mode
        var A:Float? = nil
        var B:Float? = nil
        
        var img_play = UIImage(from: .segoeMDL2, code: "PlayBadge12", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        var img_pause = UIImage(from: .segoeMDL2, code: "PauseBadge12", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))

        
        //track player's time
        var playerTimer:Timer!
        @objc func trackPlayer(){
            if(player != nil){
                if(playerStatus == "play" || playerStatus == "continue")
                {
                    //ab mode first
                    if(A != nil && B != nil)
                    {
                        if(Double(CMTimeGetSeconds(player!.currentTime())) >= TimeInterval(B!))
                        {
                            playerStatus = "finished"
                        }
                        return
                    }
                    
                    //if not in ab mode,play special split
                    if(Double(CMTimeGetSeconds(player!.currentTime())) >= TimeInterval(end_time))
                    {
                        playerStatus = "finished"
                    }
                }
            }
        }
        
        override var isSelected: Bool{
            didSet{
                if(playerStatus == "" || playerStatus == "reload"){
                    playerStatus = "pause"
                }
                
                if(playerStatus == "pause"){
                    playerStatus = "continue"
                }
                else if(playerStatus == "stop" || playerStatus == "finished"){
                    playerStatus = "play"
                }
                else{
                    playerStatus = "pause"
                }
            }
        }
        
        var playerStatus:String {
            didSet{
                if(playerStatus == "play")
                {
                    
                    imageView.image = img_pause.withRenderingMode(.alwaysTemplate)
                    
//                    do {
//                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                    } catch _ {}
                    
                    updater = CADisplayLink(target: self, selector: #selector(PlayCell.updateTimer))
                    updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
                    
                    if(A != nil && B != nil){
//                        player!.currentTime = TimeInterval(A!)
                        player!.seek(to: CMTimeMakeWithSeconds(TimeInterval(A!), 60000))
                    }
                    else{
//                        player?.currentTime = TimeInterval(start_time)
                        player!.seek(to: CMTimeMakeWithSeconds(TimeInterval(start_time), 60000))
                    }
                    player!.play()
                    
                }
                else if(playerStatus == "continue" )
                {
                    updater = CADisplayLink(target: self, selector: #selector(PlayCell.updateTimer))
                    updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
                    
                    player!.play()
                    imageView.image = img_pause.withRenderingMode(.alwaysTemplate)
                }
                else if(playerStatus == "finished" )
                {
                    player!.pause()
                    updater?.invalidate()
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                }
                else if(playerStatus == "pause" )
                {
                    player?.pause()
                    updater?.invalidate()
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                }
                else if( playerStatus == "stop")
                {
                    player?.pause()
//                    player?.currentTime = TimeInterval(start_time)
                    player!.seek(to: CMTimeMakeWithSeconds(TimeInterval(start_time), 60000))
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                    updater?.invalidate()
                }
                else if( playerStatus == "reload")
                {
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                    updater?.invalidate()
                }
            }
        }
        
        
        var timeCell:TimeCell?
//        var abCell:ABCell?
        
        var updater : CADisplayLink! = nil
        
        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_play.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
//        func initAudio(_ audiofilePath:String){
//            do {
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            } catch _ {}
//
//            do {
//                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audiofilePath))
//                player!.prepareToPlay()
//
//            } catch let error as NSError {
//                print(error)
//            }
//        }
//
//        func loadMedia(media_url:String,media_name:String){
//            let fileManager = FileManager.default
//            var paths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
//
//            let audiofilePath = paths[0].appending("/\(media_name)")
//            if !fileManager.fileExists(atPath: audiofilePath)
//            {
//                let url = URL(string:media_url)
//                downloadMedia(url!,media_name)
//            }
//            else{
//                initAudio(audiofilePath)
//            }
//        }
//
//        func downloadMedia(_ downloadUrl:URL,_ fileName:String){
//            Downloader.loadFileAsync(url: downloadUrl, fileName: fileName, completion: {filePath,error in self.initAudio(filePath!) })
//        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            playerStatus = "finished"
        }
        
        func setAB()->String{
            if(A == nil)
            {
                A = Float(CMTimeGetSeconds(player!.currentTime()))
                return "A"
            }
            
            if(B == nil)
            {
                B = Float(CMTimeGetSeconds(player!.currentTime()))
                return "AB"
            }
            
            A = nil
            B = nil
            return ""
        }
        
        func cancelAB(){
            A = nil
            B = nil
        }
        
        
        @objc func updateTimer(){
            timeCell?.textView.text = DateTimeUtil.stringFromTimeInterval(interval: CMTimeGetSeconds(player!.currentTime()))+"\n"+DateTimeUtil.stringFromTimeInterval(interval: (player?.currentItem?.duration.seconds)!)
        }
        
        override init(frame:CGRect){
            playerStatus = ""
            super.init(frame:frame)
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            
            self.playerTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(PlayCell.trackPlayer), userInfo: nil, repeats: true)
        }
        
//        func initAudioByURL(_ audiofilePath:URL){
//
//            do {
//                player = try AVAudioPlayer(contentsOf: audiofilePath)
//                player?.delegate = self
//                player!.prepareToPlay()
//
//            } catch let error as NSError {
//                print(error)
//            }
//        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    
    class ABCell:UICollectionViewCell, AVAudioRecorderDelegate{
        
        var playCell:PlayCell?
        var img_ab = UIImage(from: .segoeMDL2, code: "HorizontalTabKey", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        var img_ab_a = UIImage(from: .segoeMDL2, code: "Import", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))

        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_ab.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        var updater : CADisplayLink! = nil
        
//        var timeCell:TimeCell?
        
        var recordingSession: AVAudioSession!
        var audioRecorder: AVAudioRecorder!
        
        override var isSelected: Bool{
            didSet{
                
                let ret = playCell?.setAB()
                
                if(ret == "")
                {
                    imageView.image = img_ab.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = UIColor.gray
                }
                else if(ret == "A")
                {
                    imageView.image = img_ab_a.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = UIColor.blue
                    if(playCell?.playerStatus != "play" && playCell?.playerStatus != "continue"){
                        if(playCell?.playerStatus == "finished"){
                            playCell?.playerStatus = "play"
                        }
                        else{
                            playCell?.playerStatus = "continue"
                        }
                    }
                }
                else if(ret == "AB")
                {
                    imageView.image = img_ab.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = UIColor.blue
                }
            }
        }
        
        func cancelAB(){
            imageView.image = img_ab.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.gray
        }
        
        override init(frame:CGRect){
            super.init(frame:frame)
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class StopCell:UICollectionViewCell{
        
        var playCell:PlayCell?
        var abCell:ABCell?
        
        var img_stop = UIImage(from: .segoeMDL2, code: "Stop", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
       
        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_stop.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        override var isSelected: Bool{
            didSet{
                abCell?.cancelAB()
                playCell?.cancelAB()
                playCell?.playerStatus = "stop"
            }
        }
        
        override init(frame:CGRect){
            super.init(frame:frame)
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class ExpandCell:UICollectionViewCell{
        var parent:PlayerMenuView?
        
        var img_up = UIImage(from: .segoeMDL2, code: "ChevronUpMed", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        var img_down = UIImage(from: .segoeMDL2, code: "ChevronDownMed", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        
        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_up.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        override var isSelected: Bool{
            didSet{
                if(isSelected)
                {
                    parent?.delegate?.expandMenu(expand: true)
                    imageView.image = img_down.withRenderingMode(.alwaysTemplate)                    
                }
                else
                {
                    parent?.delegate?.expandMenu(expand: false)
                    imageView.image = img_up.withRenderingMode(.alwaysTemplate)
                }
            }
        }
        
        override init(frame:CGRect){
            super.init(frame:frame)
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}








