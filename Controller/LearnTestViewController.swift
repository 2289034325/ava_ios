//
//  LoginViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import OnePasswordExtension
import Kingfisher
import SVProgressHUD
import Alamofire
import ObjectMapper
import SnapKit
import TinderSwipeView


class LearnTestViewController: UIViewController {

    var book:UserBookModel
    var words:[WordModel]
    var questions:[QuestionModel]

    var learnRecord:LearnRecordModel

    var questionView:QuestionView
    var questionViewNext:QuestionView?

    var animating:Bool = false

    var startLocation = CGPoint()
    
    var refrenceView = ""
    
    var rImage:UIImageView =
    {
        // SwiftIconFont 做出来的图形无法缩放，放入UIImageView后始终不能填满UIImageView，在图片周围留下几个像素的空白!!!
        let img = UIImage(from: .segoeMDL2, code: "CheckMark", textColor: .white, backgroundColor: .blue, size: CGSize(width: 50, height: 50))
//        let img = UIImage(named: "flg_fr")!
        
        let iv = UIImageView()
        // 由于SwiftIconFont的图片不能填满，所以这里用背景色填满，看起来没有空白
        iv.backgroundColor = UIColor.blue
        iv.frame = CGRect(x: SCREEN_WIDTH/2-25, y: SCREEN_HEIGHT/2-25, width: 50, height: 50)
        iv.image = img.withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 25
        iv.isHidden = true
        
        return iv
    }()
    
    lazy var rImageTransform:CGAffineTransform={
        return self.rImage.transform
    }()
    
    var wImage:UIImageView =
    {
        let img = UIImage(from: .segoeMDL2, code: "Cancel", textColor: .white, backgroundColor: .red, size: CGSize(width: 50, height: 50))
        
        let iv = UIImageView()
        iv.backgroundColor = UIColor.red
        iv.frame = CGRect(x: SCREEN_WIDTH/2-25, y: SCREEN_HEIGHT/2-25, width: 50, height: 50)
        iv.image = img.withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 25
        iv.isHidden = true
        
        return iv
    }()
    
    lazy var wImageTransform:CGAffineTransform={
        return self.wImage.transform
    }()
    
    var actionFloatView: LearnTestRightFloatView!

    init(book:UserBookModel,words:[WordModel]) {

        self.book = book
        self.words = words

        if words.count == 0 {
            fatalError("need at least one words!")
        }

        learnRecord = LearnRecordModel(user_book:self.book,word_count:self.words.count)

        //生成question
        self.questions = [QuestionModel]()
        let qts = [QuestionType.MF,QuestionType.FM,QuestionType.Fill]
        for(idx,w) in self.words.enumerated(){
            let rd = LearnRecordWordModel(word:w)
            learnRecord.detail.append(rd)

            //一个word对应多个question，对应一个record detail
            //一个record detail 对应多个question
            let qs = w.createQuestions(types:qts,recordModel:rd)
            self.questions.append(contentsOf: qs)
        }
        
        
        //第一个和第二个问题初始化view
        let qst = LearnTestViewController.getRandomQuestion(self.questions,except: nil)
        self.questionView = QuestionView(frame:CGRect.zero,question:qst!)
        qst?.plusAnswerTimes()
        if self.questions.count > 1 {
            let qst2 = LearnTestViewController.getRandomQuestion(self.questions,except: qst)
            self.questionViewNext = QuestionView(frame: CGRect.zero, question: qst2!)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.view.backgroundColor = UIColor.gray

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap(_:)))
        self.view.addGestureRecognizer(tap)

        let panRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(panedView))
        self.view.addGestureRecognizer(panRecognizer)

        self.view.addSubview(questionView)
        questionView.snp.makeConstraints{(make)->Void in
            make.left.top.right.bottom.equalTo(self.view)
        }

        if self.questionViewNext != nil {
            self.view.insertSubview(questionViewNext!, belowSubview: questionView)
            questionViewNext!.snp.makeConstraints { (make) -> Void in
                make.left.top.right.bottom.equalTo(self.view)
            }
        }
        
        self.view.addSubview(rImage)
        self.view.addSubview(wImage)
        
        setupNavigationItem()
    }
    
    func setupNavigationItem(){
        
        customNavBackButton(backAction: #selector(backAction))
        
        self.navigationItem.title = "\(self.questions.count)/\(self.questions.count)"
        
        //Init ActionFloatView
        self.actionFloatView = LearnTestRightFloatView()
        self.actionFloatView.delegate = self
        self.view.addSubview(self.actionFloatView)
        self.actionFloatView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.tintColor = .black
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        let bimg = UIImage(from: .segoeMDL2, code: "More", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        rightButton.setImage(bimg.withRenderingMode(.alwaysTemplate), for: UIControlState())
        rightButton.addTarget(self, action: #selector(LearnTestViewController.rightClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    //打开公共词书页面，选择词书
    @objc func rightClick(){        
        self.actionFloatView.hide(!self.actionFloatView.isHidden)
    }

    @objc func backAction(){
        let qs = self.questions.filter { (qm: QuestionModel) -> Bool in
            return !qm.pass
        }

        if qs.count > 0{
            confirm(title:"确认",message:"测试未完成，是否确定要退出？"){(_) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    class func getRandomQuestion(_ questions:[QuestionModel],except:QuestionModel?)->QuestionModel?{
        
        let qs = questions.filter { (qm: QuestionModel) -> Bool in
            return !(qm.pass || qm.learn_record_word_model.finished) && ((except == nil) ? true : (qm.word.id != except!.word.id || qm.type != except?.type))
        }

        //回答次数少的优先出现
        let minA = qs.map { (model: QuestionModel) -> Int in return model.answer_times }.min { (v, v2) in return v<v2 }

        let minQs = qs.filter { (model: QuestionModel) -> Bool in return model.answer_times == minA! }

        return minQs.randomElement()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    @objc func panedView(sender:UIPanGestureRecognizer) {

        if self.animating{
            return
        }

        //UIGestureRecognizerState has been renamed to UIGestureRecognizer.State in Swift 4
        if (sender.state == UIGestureRecognizer.State.began) {
            startLocation = sender.location(in: self.view)
        }
        else if(sender.state == UIGestureRecognizer.State.changed){
            let currentLocation = sender.location(in: self.view)
            let dx = currentLocation.x - startLocation.x
            let dy = currentLocation.y - startLocation.y
            let distance = sqrt(dx * dx + dy * dy)
            let ratio = distance/110
            
            
            if(dx<0){
                rImage.alpha = ratio
                rImage.transform = rImageTransform.scaledBy(x: ratio, y: ratio)
                rImage.isHidden = false
                
                wImage.isHidden = true
            }
            else{
                wImage.alpha = ratio
                wImage.transform = wImageTransform.scaledBy(x: ratio, y: ratio)
                wImage.isHidden = false
                
                rImage.isHidden = true
            }
            
        }
        else if (sender.state == UIGestureRecognizer.State.ended) {
            let stopLocation = sender.location(in: self.view)
            let dx = stopLocation.x - startLocation.x
            let dy = stopLocation.y - startLocation.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance > 110 {
                if dx<0{
                    self.questionView.question.pass = true
                }
                else{
                    self.questionView.question.pass = false
                    //回答错误次数+1
                    self.questionView.question.plusWrongTimes()
                }
                
                self.handleNext(self.questionView.question.pass)
            }
            else{
                let rot = self.rImage.transform
                let scaleRot = rot.scaledBy(x: 0.0001, y: 0.0001)//如果写0的话，没有动画效果，直接就没了!!!
                let wot = self.wImage.transform
                let scaleWot = wot.scaledBy(x: 0.0001, y: 0.0001)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.rImage.transform = scaleRot
                    self.wImage.transform = scaleWot
                }, completion: {(_) in
                    
                })
            }
        }
    }
    
    func handleNext(_ pass:Bool){
        //最后一题回答错误，特殊处理，
        if self.questionViewNext == nil && self.questionView.question.pass == false{
            self.animating = true
            //冻结页面，提示10秒后重新回答
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show(withStatus: "最后一题回答错误，请在10秒后重新回答")
            
            self.questionView.closeAnswer()
            
            var tc = 10
            let timer = Timer.init(timeInterval: 1, repeats:true) { (kTimer) in
                SVProgressHUD.setStatus("最后一题回答错误，请在\(tc)秒后重新回答")
                tc -= 1
                if tc == -1{
                    SVProgressHUD.dismiss(completion: {
                        kTimer.invalidate()
                        self.animating = false
                    })
                }
            }
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            // TODO : 启动定时器
            timer.fire()
            return
        }
        
        //更新导航栏
        let nq = self.questions.filter { (qm: QuestionModel) -> Bool in
            return !(qm.pass || qm.learn_record_word_model.finished)
        }
        self.navigationItem.title = "\(nq.count)/\(self.questions.count)"
        
        //测试结束，提交
        if self.questionViewNext == nil {
            self.learnRecord.end_time = Date()
            
            //提交
            self.submitTestResult()
            
            return
        }
        
        //不是最后一题，动画切换到下一题
        self.animating = true
        self.questionView.backgroundColor = UIColor.gray
        let rTrans = self.rImage.transform
        let wTrans = self.wImage.transform
        UIView.animate(withDuration: 0.3, animations: {
            if(pass)
            {
                self.questionView.center = CGPoint(x:self.view.center.x*(-1),y:self.view.center.y)
                
                self.rImage.transform = rTrans.scaledBy(x: 2, y: 2)
                self.rImage.alpha = 0.001
            }
            else{
                self.questionView.center = CGPoint(x:self.view.center.x*(3),y:self.view.center.y)
                self.wImage.transform = wTrans.scaledBy(x: 2, y: 2)
                self.wImage.alpha = 0.001
            }
        }, completion: {(_) in
            self.questionView.removeFromSuperview()
            self.questionView = self.questionViewNext!
            //被展示后，认定为开始回答，回答次数+1
            self.questionView.question.plusAnswerTimes()
            
            //判断是否是最后一题了
            if let qst = LearnTestViewController.getRandomQuestion(self.questions,except: self.questionView.question)
            {
                self.questionViewNext = QuestionView(frame: self.view.frame, question: qst)
                self.view.insertSubview(self.questionViewNext!, belowSubview: self.questionView)
                self.questionViewNext!.snp.makeConstraints { (make) -> Void in
                    make.left.top.right.bottom.equalTo(self.view)
                }
            }
            else{
                self.questionViewNext = nil
            }
            
            self.animating = false
        })
    }

    @objc func viewTap(_ sender:UITapGestureRecognizer) {
        if self.animating{
            return
        }

        self.questionView.showAnswer()
    }

    func submitTestResult(){

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show(withStatus: "测试完成，正在提交")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // Put your code which should be executed with a delay here
            _ = DictionaryApi.provider
                .requestAPI(.submitResult(self.learnRecord))
                .subscribe(onNext: { (response) in
                    SVProgressHUD.setStatus("提交成功，正在返回")
                    SVProgressHUD.dismiss(withDelay: 1, completion: {
                        //返回
                        if self.refrenceView == "wordscan"{
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                        }
                        else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }, onError: { (error) in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: error.rawString())
                })
        })
        
//        _ = DictionaryApi.provider
//                .requestAPI(.submitResult(self.learnRecord))
//                .subscribe(onNext: { (response) in
//                    SVProgressHUD.showSuccess(withStatus: "提交成功，正在返回")
//                    SVProgressHUD.dismiss(withDelay: 2, completion: {
//                        //返回
//                        self.navigationController?.popViewController(animated: true)
//                    })
//                }, onError: { (error) in
//                    SVProgressHUD.dismiss()
//                    SVProgressHUD.showError(withStatus: error.rawString())
//                })
    }
}

extension LearnTestViewController: LearnTestFloatViewDelegate {
    func floatViewTapItemIndex(_ type: LearnTestFloatViewItemType) {
        switch type {
        // 将当前单词标记为已掌握
        case .setFinished:
            self.questionView.question.pass = true
            self.questionView.question.learn_record_word_model.finished = true
            self.handleNext(true)
            break
        default:
            break
        }
    }
}

