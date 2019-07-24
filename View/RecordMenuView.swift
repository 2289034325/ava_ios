//
//  MenuView.swift
//  Speech
//
//  Created by 菜白 on 2018/8/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(RecordCell.self, forCellWithReuseIdentifier: "recordcell")
        collectionView.register(PlayCell.self, forCellWithReuseIdentifier: "playcell")
        collectionView.register(StopCell.self, forCellWithReuseIdentifier: "stopcell")
        collectionView.register(TimeCell.self, forCellWithReuseIdentifier: "timecell")
        collectionView.register(BlankCell.self, forCellWithReuseIdentifier: "blankcell")
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
        }
        else if(indexPath.row == 3){
            //音频时长
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timecell", for: indexPath)
            timeCell = cell as? TimeCell
            recordCell?.timeCell = timeCell
            playCell?.timeCell = timeCell
        }
        else if(indexPath.row == 4){
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blankcell", for: indexPath)
        }
        
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class RecordCell:UICollectionViewCell, AVAudioRecorderDelegate{
        
        var playCell:PlayCell?
        var isRecording:Bool = false
        
        let imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = UIImage(named: "record")?.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        var updater : CADisplayLink! = nil
        
        var timeCell:TimeCell?
        
        var recordingSession: AVAudioSession!
        var audioRecorder: AVAudioRecorder!
        
        override var isSelected: Bool{
            didSet{
                imageView.tintColor = isSelected ? UIColor.blue : UIColor.gray
                
                playCell?.playerStatus = "reload"
                
                if(isSelected)
                {
                    isRecording = true;
                    //开始录音
                    startRecording()
                }
                else
                {
                    isRecording = false
                    finishRecording(success: true)
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
        
        func startRecording(){
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() {
                    allowed in
                    //                [unowned self] allowed in
                    //                DispatchQueue.main.async {
                    //                    if allowed {
                    //                        //                        self.loadRecordingUI()
                    ////                        print("allowed")
                    //                    } else {
                    //                        // failed to record!
                    ////                        print("not allowed")
                    //                    }
                    //                }
                }
            } catch {
                print(error)
            }
            
            let audioFilename = RecordCell.getAudioName()
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVLinearPCMBitDepthKey: 16,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                //            NSObject.cancelPreviousPerformRequests(withTarget: audioRecorder!)
                //            audioRecorder!.perform(#selector(player!.pause), with: nil, afterDelay: stopTime)
                updater = CADisplayLink(target: self, selector: #selector(RecordCell.updateTimer))
                updater.preferredFramesPerSecond = 1
                updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
                
                //            recordButton.setTitle("Tap to Stop", for: .normal)
            } catch {
                print(error)
                finishRecording(success: false)
            }
        }
        
        @objc func updateTimer(){
            timeCell?.textView.text = "00:00:00"+"\n"+DateTimeUtil.stringFromTimeInterval(interval: audioRecorder.currentTime)
        }
        
        func finishRecording(success: Bool) {
            updater.invalidate()
            audioRecorder.stop()
            audioRecorder = nil
            
            if success {
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
    
    class PlayCell:UICollectionViewCell,AVAudioPlayerDelegate{
        
        private var player:AVAudioPlayer?
        
        var playerStatus:String {
            didSet{
                if(playerStatus == "play")
                {
                    imageView.image = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
                    
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    } catch _ {}
                    
                    updater = CADisplayLink(target: self, selector: #selector(PlayCell.updateTimer))
                    updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
                    
                    player?.play()
                }
                else if(playerStatus == "pause" )
                {
                    player?.pause()
                    updater?.invalidate()
                    imageView.image = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
                }
                else if( playerStatus == "stop")
                {
                    player?.stop()
                    player?.currentTime = 0
                    imageView.image = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
                    updater?.invalidate()
                }
                else if( playerStatus == "reload")
                {
                    player?.stop()
                    imageView.image = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
                    updater?.invalidate()
                }
            }
        }
        
        
        var timeCell:TimeCell?
        var recordCell:RecordCell?
        
        var updater : CADisplayLink! = nil
        
        let imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
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
                
                if(playerStatus == "" || playerStatus == "reload"){
                    let audioFilename = RecordCell.getAudioName()
                    initAudio(audioFilename)
                    
                    playerStatus = "pause"
                }
                
                if(playerStatus == "pause" || playerStatus == "stop"){
                    playerStatus = "play"
                }
                else{
                    playerStatus = "pause"
                }
            }
        }
        
        @objc func updateTimer(){
            timeCell?.textView.text = DateTimeUtil.stringFromTimeInterval(interval: (player?.currentTime)!)+"\n"+DateTimeUtil.stringFromTimeInterval(interval: (player?.duration)!)
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
        
        func initAudio(_ audiofilePath:URL){
            
            do {
                player = try AVAudioPlayer(contentsOf: audiofilePath)
                player?.delegate = self
                player!.prepareToPlay()
                
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
        
        let imageView:UIImageView={
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            iv.image = UIImage(named: "stop")?.withRenderingMode(.alwaysTemplate)
            iv.tintColor = UIColor.gray
            iv.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            
            return iv
        }()
        
        override var isSelected: Bool{
            didSet{
                //            imageView.tintColor = isSelected ? UIColor.blue : UIColor.gray
                //            playCell?.player?.stop()
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
    
    class BlankCell:UICollectionViewCell{
        override init(frame:CGRect){
            super.init(frame:frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}

