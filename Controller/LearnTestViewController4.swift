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


class LearnTestViewController4: UIViewController {

    var book:UserBookModel
    var words:[WordModel]
    var questions:[QuestionModel]

    var learnRecord:LearnRecordModel

    var questionView:QuestionView2
    var questionViewNext:QuestionView2?

    var animating:Bool = false

    var startLocation = CGPoint()
    
    var refrenceView = ""

//    var leftFinishPoint = CGPoint.zero
//    var rightFinishPoint = CGPoint.zero

//    convenience init(book:BookModel,words:[WordModel]) {
//        self.init(book:book,words:words)
//    }

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
        let qst = LearnTestViewController4.getRandomQuestion(self.questions,except: nil)
        self.questionView = QuestionView2(frame:CGRect.zero,question:qst!)
        qst?.plusAnswerTimes()
        if self.questions.count > 1 {
            let qst2 = LearnTestViewController4.getRandomQuestion(self.questions,except: qst)
            self.questionViewNext = QuestionView2(frame: CGRect.zero, question: qst2!)
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

        self.navigationItem.title = "\(self.questions.count)/\(self.questions.count)"

//        let menuButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
//        let bimg = UIImage(from: .segoeMDL2, code: "ChevronLeft", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
//        menuButton.image = bimg
//        menuButton.tintColor = .black
//        menuButton.imageInsets = UIEdgeInsetsMake(0, -12, 0, 0)
//        self.navigationItem.leftBarButtonItem = menuButton
        
        customNavBackButton(backAction: #selector(backAction))        

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
            return !qm.pass && ((except == nil) ? true : (qm.word.id != except!.word.id || qm.type != except?.type))
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
        } else if (sender.state == UIGestureRecognizer.State.ended) {
            let stopLocation = sender.location(in: self.view)
            let dx = stopLocation.x - startLocation.x
            let dy = stopLocation.y - startLocation.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance > 110 {
                let leftFinishPoint = CGPoint(x: -self.questionView.center.x*2, y: self.questionView.center.y)
                let rightFinishPoint = CGPoint(x: self.questionView.center.x*3, y: self.questionView.center.y)
                var finishPoint = CGPoint.zero
                
                if dx<0{
                    finishPoint = leftFinishPoint
                    self.questionView.question.pass = true
                }
                else{
                    finishPoint = rightFinishPoint
                    self.questionView.question.pass = false
                    //回答错误次数+1
                    self.questionView.question.plusWrongTimes()
                }
                
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
                    return !qm.pass
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
                UIView.animate(withDuration: 0.3, animations: {
                    self.questionView.center = finishPoint
                }, completion: {(_) in
                    self.questionView.removeFromSuperview()
                    self.questionView = self.questionViewNext!
                    //被展示后，认定为开始回答，回答次数+1
                    self.questionView.question.plusAnswerTimes()
                    
                    //判断是否是最后一题了
                    if let qst = LearnTestViewController4.getRandomQuestion(self.questions,except: self.questionView.question)
                    {
                        self.questionViewNext = QuestionView2(frame: self.view.frame, question: qst)
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
        }
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
