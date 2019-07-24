//
//  ArticleController2.swift
//  Speech
//
//  Created by 菜白 on 2018/8/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class SpeechController: UIViewController,UITableViewDataSource,MenuExpandDelegate {
    
    func expandMenu(expand: Bool) {
        if(expand){
            constraintsOfRecordMenu[4].constant = 40
        }
        else{
            constraintsOfRecordMenu[4].constant = 0
        }
    }
    

    var articleId:Int = 0
    var articleTitle:String = ""
    var article: ArticleModel?
    var paragraphs = [ParagraphModel]()
    
    let tableView = UITableView()
    let recrdMenuView = RecordMenuView()
    let playerMenuView = PlayerMenuView()
    
    var constraintsOfRecordMenu:[NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSubviews()
        
        loadArticle()
        
        setNavigationBar()
    }
    
    
    func setSubviews(){
                
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        self.view.addSubview(playerMenuView)
        self.view.addSubview(recrdMenuView)
        
        var views = [String:UIView]()
        views.updateValue(tableView, forKey: "tb")
        views.updateValue(playerMenuView, forKey: "pmn")
        views.updateValue(recrdMenuView, forKey: "rmn")        
        constraintsOfRecordMenu = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tb]-0-[pmn(40)]-0-[rmn(40)]|", options: [], metrics: nil, views: views)
//        constraintsWithoutRecordMenu = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tb]-0-[pmn(40)]-0-[rmn(10)]|", options: [], metrics: nil, views: views)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        recrdMenuView.translatesAutoresizingMaskIntoConstraints = false
        playerMenuView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tb]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pmn]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rmn]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(constraintsOfRecordMenu)
        
        playerMenuView.delegate = self
        
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return paragraphs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell()
        var lbls = [String:UITextView]()
        var vFormat = "V:|"
        
        for (index,split) in paragraphs[indexPath.row].splits.enumerated()
        {
            let label:UITextView = UITextView()
            label.isEditable=false
            label.font = .systemFont(ofSize:20)
            label.isScrollEnabled=false
            label.textAlignment = .left
            label.accessibilityElements = [split]
//            label.text = String(paragraphs[indexPath.row].text.substring(split.startIndex..<split.endIndex+1))
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let splitTap = UITapGestureRecognizer(target: self, action: #selector(SpeechController.splitTapAction))
            splitTap.numberOfTapsRequired = 1
            let splitDbTap = UITapGestureRecognizer(target: self, action: #selector(SpeechController.splitDbTapAction))
            splitDbTap.numberOfTapsRequired = 2
            
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(splitTap)
            label.addGestureRecognizer(splitDbTap)
            
            lbls.updateValue(label, forKey: "v\(index)")
            
            if(index == paragraphs[indexPath.row].splits.count-1)
            {
                vFormat += "[v\(index)]|"
            }
            else{
                vFormat += "[v\(index)]-0-"
            }
            
            cell.contentView.addSubview(label)
            
        }
        
        for lable in lbls.keys
        {
            cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[\(lable)]-10-|", options: [], metrics: nil, views: lbls))
        }
        
        cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: [], metrics: nil, views: lbls))
        
        return cell
    }
    
    @objc func splitTapAction(sender:UITapGestureRecognizer) {
        
        let lbl = sender.view as! UITextView
        let split = lbl.accessibilityElements![0] as! ParagraphSplitModel
        
        //cancel selection
        lbl.selectedTextRange = nil
        
        if(playerMenuView.playCell?.playerStatus != "play" &&
            playerMenuView.playCell?.playerStatus != "continue" &&
            playerMenuView.playCell?.playerStatus != "pause" )
        {
            playerMenuView.playCell?.startTime = split.startTime
            playerMenuView.playCell?.endTime = split.endTime
        }
//        NSObject.cancelPreviousPerformRequests(withTarget: player!)
//
//        player!.currentTime = TimeInterval(split.startTime)
//        player!.play()
//        let stopTime = TimeInterval(split.endTime-split.startTime)
//        player!.perform(#selector(player!.pause), with: nil, afterDelay: stopTime)
    }
    
    @objc func splitDbTapAction(sender:UITapGestureRecognizer) {
        
        let lbl = sender.view as! UITextView
        let split = lbl.accessibilityElements![0] as! ParagraphSplitModel
        
        playerMenuView.abCell?.cancelAB()
        playerMenuView.playCell?.cancelAB()
        playerMenuView.playCell?.startTime = split.startTime
        playerMenuView.playCell?.endTime = split.endTime
        playerMenuView.playCell?.playerStatus = "play"
        
//        NSObject.cancelPreviousPerformRequests(withTarget: player!)
//
//        player!.currentTime = TimeInterval(split.startTime)
//        player!.play()
//        let stopTime = TimeInterval(split.endTime-split.startTime)
//        player!.perform(#selector(player!.pause), with: nil, afterDelay: stopTime)
    }
    
    func setNavigationBar(){
        navigationItem.hidesBackButton=false
        navigationItem.title = self.articleTitle
    }
    
    func loadArticle()
    {        
        HttpClient.getArticle(articleId: self.articleId, complitionHandler: { articles in
            self.article = articles
            self.paragraphs = self.article!.paragraphs
            if(self.article!.paragraphs.count>0)
            {
                if(self.article!.paragraphs[0].splits.count>0){
                        self.tableView.reloadData()
                        self.playerMenuView.playCell?.endTime = self.article!.paragraphs[0].splits[0].endTime
                        self.playerMenuView.playCell?.loadAudio(audioUrl: self.article!.audioUrl, audioName: self.article!.audioName)
                    }
            }
        })
    }
    
    
    
    
}
