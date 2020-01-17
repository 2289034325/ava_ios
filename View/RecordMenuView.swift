//
//  MenuView.swift
//  Speech
//
//  Created by 菜白 on 2018/8/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD
import RxSwift
import Kingfisher

class RecordMenuView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    var recordCell:RecordCell?
    var playCell:PlayCell?
    var stopCell:StopCell?
    var timeCell:TimeCell?
    var menuCell:MenuCell?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        collectionView.register(RecordCell.self, forCellWithReuseIdentifier: "recordcell")
        collectionView.register(PlayCell.self, forCellWithReuseIdentifier: "playcell")
        collectionView.register(StopCell.self, forCellWithReuseIdentifier: "stopcell")
        collectionView.register(TimeCell.self, forCellWithReuseIdentifier: "timecell")
        collectionView.register(BlankCell.self, forCellWithReuseIdentifier: "blankcell")
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: "menucell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        collectionView.allowsMultipleSelection = true
        
        addSubview(collectionView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: [], metrics: nil, views: ["v0":collectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: [], metrics: nil, views: ["v0":collectionView]))    
    }
    
    // 只有加在这里才有用，fuck!!!
    override func didMoveToWindow() {
        // 必须加layoutIfNeeded，边框才会出现!!!
        self.layoutIfNeeded()
        self.layer.addBorder(edge: .top, color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), thickness: 0.5)
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
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvc", for: indexPath) as! MenuCell
        
//        let cell = MenuCell()
        
//        cell.imageView.image = UIImage(named:imgNames[indexPath.row])?.withRenderingMode(.alwaysTemplate)
//        cell.imageView.tintColor = UIColor.gray
//
        var cell = UICollectionViewCell()
        
        if(indexPath.row == 0){
            //录音
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recordcell", for: indexPath)
            recordCell = cell as? RecordCell
        }
        else if(indexPath.row == 1){
            //播放，暂停
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playcell", for: indexPath)
            playCell = cell as? PlayCell
            playCell?.recordCell = recordCell
            recordCell?.playCell = playCell
        }
        else if (indexPath.row == 2){
            //停止
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stopcell", for: indexPath)
            stopCell = cell as? StopCell
            stopCell?.playCell = playCell
            stopCell?.recordCell = recordCell
        }
        else if(indexPath.row == 3){
            //音频时长
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timecell", for: indexPath)
            timeCell = cell as? TimeCell
            recordCell?.timeCell = timeCell
        }
        else if(indexPath.row == 4){
            playCell?.timeCell = timeCell
            playCell?.initAudio()
            playCell?.updateTimer()
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menucell", for: indexPath)
            menuCell = cell as? MenuCell
        }
        
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopPlayingAndRecording(){
        recordCell?.finishRecording(success: true)
        playCell?.playerStatus = "stop"
    }
    
    
    
    class RecordCell:UICollectionViewCell, AVAudioRecorderDelegate{
        
        var playCell:PlayCell?
        var isRecording:Bool = false
        
        var img_record = UIImage(from: .segoeMDL2, code: "MicOn", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        
        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_record.withRenderingMode(.alwaysTemplate)
            iv.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        var updater : CADisplayLink! = nil
        
        var timeCell:TimeCell?
        
        var recordingSession: AVAudioSession!
        var audioRecorder: AVAudioRecorder!
        
        override var isSelected: Bool{
            didSet{
                playCell?.playerStatus = "reload"
                
                if(!isRecording)
                {
                    recordingSession = AVAudioSession.sharedInstance()
                    do {
                        try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try self.recordingSession.setActive(true)
                        //[unowned self] 如果不加，会引起崩溃!!!
                        recordingSession.requestRecordPermission() { [unowned self] allowed in
                            DispatchQueue.main.async {
                                if allowed {
                                    let audioFilename = RecordCell.getAudioName()
                                    let settings = [
                                        AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                        AVLinearPCMBitDepthKey: 16,
                                        AVSampleRateKey: 44100,
                                        AVNumberOfChannelsKey: 1,
                                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
                                    ]

                                    do {
                                        self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                                        self.audioRecorder.delegate = self
                                        self.audioRecorder.record()

                                        self.updater = CADisplayLink(target: self, selector: #selector(RecordCell.updateTimer))
                                        self.updater.preferredFramesPerSecond = 1
                                        self.updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)

                                        self.isRecording = true;
                                        self.imageView.tintColor = #colorLiteral(red: 0, green: 0.5032967925, blue: 1, alpha: 1)

                                    } catch {
                                        print(error)
                                    }
                                }
                                else {
                                    let alertView = UIAlertView(title: "无法访问您的麦克风" , message: "请到设置 -> 隐私 -> 麦克风 ，打开访问权限", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "好的")
                                    alertView.show()
                                }
                            }
                        }
                    }catch {
                        print(error)
                    }
                }
                else
                {
                    isRecording = false
                    finishRecording(success: true)
                    
                    // 恢复到播放模式，否则播放的声音会很小
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    } catch _ {}
                    
                    imageView.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
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
        
        public static func getAudioName()->URL{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let folder = paths[0]
            let audioFilename = folder.appendingPathComponent("recording.wav")
            
            return audioFilename
        }
        
        func startRecording(_ obs:AnyObserver<Bool>){
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try recordingSession.setActive(true)
                
                recordingSession.requestRecordPermission() { allowed in

                    DispatchQueue.main.async {
                        if !allowed{
                                
                                let controller = UIAlertController(title: "没有麦克风权限", message: "请在\"设置-隐私-麦克风\"打开麦克风", preferredStyle: .alert)
                                controller.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))

        //                        let sharedApplication = KingfisherWrapper<UIApplication>.shared
        //                        let vController = sharedApplication?.keyWindow?.rootViewController
                                let vController = self.findViewController()
                                vController!.present(controller, animated: true, completion: nil)
                            
                        }
                        else{
                            let audioFilename = RecordCell.getAudioName()
                            
                            let settings = [
                                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                AVLinearPCMBitDepthKey: 16,
                                AVSampleRateKey: 44100,
                                AVNumberOfChannelsKey: 1,
                                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
                            ]
                            
                            do {
                                self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                                self.audioRecorder.delegate = self
                                self.audioRecorder.record()
                                
                                self.updater = CADisplayLink(target: self, selector: #selector(RecordCell.updateTimer))
                                self.updater.preferredFramesPerSecond = 1
                                self.updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
                                
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    obs.onNext(allowed)
                }
            } catch {
                print(error)
            }
            
//            if !isAllowed{
//                return false
//            }
//
//            let audioFilename = RecordCell.getAudioName()
//
//            let settings = [
//                AVFormatIDKey: Int(kAudioFormatLinearPCM),
//                AVLinearPCMBitDepthKey: 16,
//                AVSampleRateKey: 44100,
//                AVNumberOfChannelsKey: 1,
//                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
//            ]
//
//            do {
//                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//                audioRecorder.delegate = self
//                audioRecorder.record()
//
//                //            NSObject.cancelPreviousPerformRequests(withTarget: audioRecorder!)
//                //            audioRecorder!.perform(#selector(player!.pause), with: nil, afterDelay: stopTime)
//                updater = CADisplayLink(target: self, selector: #selector(RecordCell.updateTimer))
//                updater.preferredFramesPerSecond = 1
//                updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
//
//                //            recordButton.setTitle("Tap to Stop", for: .normal)
//            } catch {
//                print(error)
//                return false
//            }
//
//            return true
        }
        
        @objc func updateTimer(){
            timeCell?.textView.text = "00:00:00"+"\n"+DateTimeUtil.stringFromTimeInterval(interval: audioRecorder.currentTime)
        }
        
        func finishRecording(success: Bool) {
//            imageView.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
//            isSelected = false
            updater?.invalidate()
            audioRecorder?.stop()
            audioRecorder = nil
            
            if success {
                // reload player
                playCell?.initAudio()
                //            recordButton.setTitle("Tap to Re-record", for: .normal)
            } else {
                //            recordButton.setTitle("Tap to Record", for: .normal)
            }
        }
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            if !flag {
                finishRecording(success: false)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class MenuCell:UICollectionViewCell{
        
        var imgButton:UIButton={
            var img_play = UIImage(from: .segoeMDL2, code: "GlobalNavigationButton", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            btn.contentMode = .center
            btn.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
            btn.setImage(img_play.withRenderingMode(.alwaysTemplate), for: UIControlState())
            btn.addTarget(self, action: #selector(SpeechController.expandMenu), for: .touchUpInside)
            return btn
        }()
        
        override init(frame:CGRect){
            super.init(frame:frame)
            
//            addSubview(imgButton)
            
//            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(30)]", options: [], metrics: nil, views: ["v0":imgButton]))
//            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":imgButton]))
//
//            addConstraint(NSLayoutConstraint(item: imgButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
//            addConstraint(NSLayoutConstraint(item: imgButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToWindow() {
            addSubview(imgButton)
            imgButton.snp.makeConstraints { (make) in
                make.top.right.bottom.left.equalTo(self)
            }
        }
        
    }
    
    class PlayCell:UICollectionViewCell,AVAudioPlayerDelegate{
        
        private var player:AVAudioPlayer?
        
        var img_play = UIImage(from: .segoeMDL2, code: "PlayBadge12", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        var img_pause = UIImage(from: .segoeMDL2, code: "PauseBadge12", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        
        var playerStatus:String {
            didSet{
                if(playerStatus == "play")
                {
                    imageView.image = img_pause.withRenderingMode(.alwaysTemplate)
                    
                    updater?.invalidate()
                    updater = CADisplayLink(target: self, selector: #selector(PlayCell.updateTimer))
                    updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
                    
                    player?.play()
                }
                else if(playerStatus == "pause" )
                {
                    player?.pause()
                    updater?.invalidate()
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                }
                else if( playerStatus == "stop")
                {
                    player?.stop()
                    player?.currentTime = 0
                    updateTimer()
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                    updater?.invalidate()
                }
                else if( playerStatus == "reload")
                {
                    player?.stop()
                    imageView.image = img_play.withRenderingMode(.alwaysTemplate)
                    updater?.invalidate()
                }
            }
        }
        
        
        var timeCell:TimeCell?
        var recordCell:RecordCell?
        
        var updater : CADisplayLink! = nil
        
        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_play.withRenderingMode(.alwaysTemplate)
            iv.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            playerStatus = "stop"
        }
        
        override var isSelected: Bool{
            didSet{
                
                if(recordCell?.isRecording)!
                {
                    return;
                }
                
                // 判断录音文件是否存在
                if(!FileManager().fileExists(atPath: RecordCell.getAudioName().path))
                {
                    return;
                }
                
                if(playerStatus == "" || playerStatus == "reload"){
                    initAudio()
                    
                    playerStatus = "pause"
                }
                
                if(playerStatus == "pause" || playerStatus == "stop"){
                    // 判断录音文件是否存在
                    if(FileManager().fileExists(atPath: RecordCell.getAudioName().path))
                    {
                        playerStatus = "play"
                    }
                }
                else{
                    playerStatus = "pause"
                }
            }
        }
        
        @objc func updateTimer(){
            if((player) != nil){
                timeCell?.textView.text = DateTimeUtil.stringFromTimeInterval(interval: (player?.currentTime)!)+"\n"+DateTimeUtil.stringFromTimeInterval(interval: (player?.duration)!)
            }
            else{

                timeCell?.textView.text = "00:00:00"+"\n"+"00:00:00"
            }
        }
        
        override init(frame:CGRect){
            playerStatus = ""
            super.init(frame:frame)
            
            addSubview(imageView)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(30)]", options: [], metrics: nil, views: ["v0":imageView]))
            
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        func initAudio(){
            
            do {
                let audiofilePath = RecordCell.getAudioName()
                // 判断录音文件是否存在
                if(FileManager().fileExists(atPath: audiofilePath.path))
                {
                    player = try AVAudioPlayer(contentsOf: audiofilePath)
                    player?.delegate = self
                    player!.prepareToPlay()
                    updateTimer()
                }
                
            } catch let error as NSError {
                print(error)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class StopCell:UICollectionViewCell{
        
        var playCell:PlayCell?
        var recordCell:RecordCell?
        
        var img_stop = UIImage(from: .segoeMDL2, code: "Stop", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        
        lazy var imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = img_stop.withRenderingMode(.alwaysTemplate)
            iv.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        override var isSelected: Bool{
            didSet{
                //            imageView.tintColor = isSelected ? UIColor.blue : UIColor.gray
                //            playCell?.player?.stop()
                // 录音过程中，不做响应
                if(recordCell!.isRecording)
                {
                    return
                }
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
    
    class TimeCell:UICollectionViewCell{
        let textView:UITextView={
            let tv = UITextView()
            tv.translatesAutoresizingMaskIntoConstraints = false
            
            tv.text = "00:00:00"+"\n"+"00:00:00"
            tv.tintColor = #colorLiteral(red: 0.325210184, green: 0.325210184, blue: 0.325210184, alpha: 1)
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
    
    class BlankCell:UICollectionViewCell{
        override init(frame:CGRect){
            super.init(frame:frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}

