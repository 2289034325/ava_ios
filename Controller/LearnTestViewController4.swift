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

    var book:BookModel?
    var words:[WordModel]?
    var questions=[QuestionModel]()

    var questionView:QuestionView2?// = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    var questionViewNext:QuestionView2?

//    var leftFinishPoint = CGPoint.zero
//    var rightFinishPoint = CGPoint.zero

    var animating:Bool = false

    var startLocation = CGPoint()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.view.backgroundColor = UIColor.gray

//        self.leftFinishPoint = CGPoint(x: -self.view.center.x*2, y: self.view.center.y)
//        self.rightFinishPoint = CGPoint(x: self.view.center.x*3, y: self.view.center.y)

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTap(_:)))
        self.view.addGestureRecognizer(tap)

//        let swipeLeft = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
//        swipeLeft.direction = .left
//        self.view.addGestureRecognizer(swipeLeft)
//
//        let swipeRight = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
//        swipeRight.direction = .right
//        self.view.addGestureRecognizer(swipeRight)

        let panRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(panedView))
        self.view.addGestureRecognizer(panRecognizer)

        //生成question
        let qts = [QuestionType.MF,QuestionType.FM,QuestionType.Fill]
        for(idx,w) in self.words!.enumerated(){
            self.questions.append(contentsOf: w.createQuestions(types:qts))
        }

        self.questionView = QuestionView2(frame:self.view.frame,question:questions[0])
        self.questionViewNext = QuestionView2(frame:self.view.frame,question:questions[1])

        self.view.addSubview(questionView!)
        self.view.insertSubview(questionViewNext!, belowSubview: questionView!)

        questionView!.snp.makeConstraints{(make)->Void in
            make.left.top.right.bottom.equalTo(self.view)
        }
        questionViewNext!.snp.makeConstraints{(make)->Void in
            make.left.top.right.bottom.equalTo(self.view)
        }
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
                let leftFinishPoint = CGPoint(x: -self.questionView!.center.x*2, y: self.questionView!.center.y)
                let rightFinishPoint = CGPoint(x: self.questionView!.center.x*3, y: self.questionView!.center.y)

                self.animating = true
                self.questionView!.backgroundColor = UIColor.gray

                if dx<0{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.questionView!.center = leftFinishPoint
                    }, completion: {(_) in
                        self.questionView!.removeFromSuperview()
                        self.questionView = self.questionViewNext
                        self.questionViewNext = QuestionView2(frame:self.view.frame,question:self.questions.randomElement()!)
                        self.view.insertSubview(self.questionViewNext!, belowSubview: self.questionView!)
                        self.questionViewNext!.snp.makeConstraints{(make)->Void in
                            make.left.top.right.bottom.equalTo(self.view)
                        }
                        self.animating = false
                    })
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.questionView!.center = rightFinishPoint
                    }, completion: {(_) in
                        self.questionView!.removeFromSuperview()
                        self.questionView = self.questionViewNext
                        self.questionViewNext = QuestionView2(frame:self.view.frame,question:self.questions.randomElement()!)
                        self.view.insertSubview(self.questionViewNext!, belowSubview: self.questionView!)
                        self.questionViewNext!.snp.makeConstraints{(make)->Void in
                            make.left.top.right.bottom.equalTo(self.view)
                        }
                        self.animating = false
                    })
                }
            }
        }
    }

    @objc func viewTap(_ sender:UITapGestureRecognizer) {
        if self.animating{
            return
        }

        self.questionView?.showAnswer()
    }

    @objc func swipe(_ recognizer:UISwipeGestureRecognizer){

        if self.animating{
            return
        }

        let leftFinishPoint = CGPoint(x: -self.questionView!.center.x*2, y: self.questionView!.center.y)
        let rightFinishPoint = CGPoint(x: self.questionView!.center.x*3, y: self.questionView!.center.y)

        if recognizer.direction == .left{
            self.questionView!.backgroundColor = UIColor.gray
            self.animating = true
            UIView.animate(withDuration: 3, animations: {
                self.questionView!.center = leftFinishPoint
            }, completion: {(_) in
                self.questionView!.removeFromSuperview()
                self.questionView = self.questionViewNext
                self.questionViewNext = QuestionView2(frame:self.view.frame,question:self.questions.randomElement()!)
                self.view.insertSubview(self.questionViewNext!, belowSubview: self.questionView!)
                self.questionViewNext!.snp.makeConstraints{(make)->Void in
                    make.left.top.right.bottom.equalTo(self.view)
                }
                self.animating = false
            })

        }else if recognizer.direction == .right{
            self.questionView!.backgroundColor = UIColor.gray
            self.animating = true
            UIView.animate(withDuration: 3, animations: {
                self.questionView!.center = rightFinishPoint
            }, completion: {(_) in
                self.questionView!.removeFromSuperview()
                self.questionView = self.questionViewNext
                self.questionViewNext = QuestionView2(frame:self.view.frame,question:self.questions.randomElement()!)
                self.view.insertSubview(self.questionViewNext!, belowSubview: self.questionView!)
                self.questionViewNext!.snp.makeConstraints{(make)->Void in
                    make.left.top.right.bottom.equalTo(self.view)
                }
                self.animating = false
            })
        }
    }
}
