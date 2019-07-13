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

    var book:BookModel
    var words:[WordModel]
    var questions:[QuestionModel]

    var learnRecord:LearnRecordModel

    var questionView:QuestionView2
    var questionViewNext:QuestionView2?

    var animating:Bool = false

    var startLocation = CGPoint()

//    var leftFinishPoint = CGPoint.zero
//    var rightFinishPoint = CGPoint.zero

//    convenience init(book:BookModel,words:[WordModel]) {
//        self.init(book:book,words:words)
//    }

    init(book:BookModel,words:[WordModel]) {

        self.book = book
        self.words = words

        if words.count == 0{
            fatalError("need at least one word!")
        }

        learnRecord = LearnRecordModel(book_id:self.book.id,word_count:self.words.count)

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



//        super.init(nibName: nil, bundle: nil)

        self.questionView = QuestionView2(frame:CGRect.zero,question:questions[0])
        if self.words.count >= 1 {
            self.questionViewNext = QuestionView2(frame: CGRect.zero, question: questions[1])
        }
//        self.questionView = QuestionView2(frame:CGRect.zero,question:questions[0])

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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<Back", style: .plain, target: self, action: #selector(backAction))

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

    func getRandomQuestion()->QuestionModel?{
        let qs = self.questions.filter { (qm: QuestionModel) -> Bool in
            return !qm.pass
        }

        if qs.count == 0{
            return nil
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

            print(distance)

            if distance > 110 {
                let leftFinishPoint = CGPoint(x: -self.questionView.center.x*2, y: self.questionView.center.y)
                let rightFinishPoint = CGPoint(x: self.questionView.center.x*3, y: self.questionView.center.y)
                var finishPoint = CGPoint.zero

                self.questionView.backgroundColor = UIColor.gray

                if dx<0{
                    finishPoint = leftFinishPoint
                    self.questionView.question.pass = true
                }
                else{
                    finishPoint = rightFinishPoint
                    self.questionView.question.pass = false
                    //回答错误次数+1
                    self.questionView.question.learn_record_word_model.wrong_times += 1
                }

                let nq = self.questions.filter { (qm: QuestionModel) -> Bool in
                    return !qm.pass
                }
                self.navigationItem.title = "\(nq.count)/\(self.questions.count)"

                guard let qst = self.getRandomQuestion() else {
                    self.learnRecord.end_time = Date()

                    //提交
                    submitTestResult()

                    //返回
                    self.navigationController?.popViewController(animated: true)

                    return
                }

                self.animating = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.questionView.center = finishPoint
                }, completion: {(_) in
                    self.questionView.removeFromSuperview()
                    self.questionView = self.questionViewNext!
                    self.questionViewNext = QuestionView2(frame: self.view.frame, question: qst)
                    self.view.insertSubview(self.questionViewNext!, belowSubview: self.questionView)
                    self.questionViewNext!.snp.makeConstraints { (make) -> Void in
                        make.left.top.right.bottom.equalTo(self.view)
                    }

                    //被展示后，认定为开始回答，回答次数+1
                    self.questionView.question.learn_record_word_model.answer_times += 1

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

        do {
//            let jsonEncoder = JSONEncoder()
//            let jsonData = try jsonEncoder.encode(self.learnRecord)
//            let json = String(data: jsonData, encoding: String.Encoding.utf8)

            _ = DictionaryApi.provider
                    .requestAPI(.submitResult(self.learnRecord))
                    .subscribe(onNext: { (response) in
                        //返回
                        self.navigationController?.popViewController(animated: true)

                    }, onError: { (error) in
                        SVProgressHUD.showError(withStatus: error.rawString())

                    })
        }catch {
            SVProgressHUD.showError(withStatus: "提交失败")
        }
    }
}
