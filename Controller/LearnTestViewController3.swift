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


class LearnTestViewController3: UIViewController {

    var book:BookModel?
    var words:[WordModel]?
    var questions=[QuestionModel]()

    var theresoldMargin = (UIScreen.main.bounds.size.width/2)
    var xCenter: CGFloat = 0.0
    var yCenter: CGFloat = 0.0
    var originalPoint = CGPoint.zero
    var bufferSize:Int = 3
    var loadedViews = [QuestionView2]()
    var questionView:QuestionView2?// = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

    var curr_index = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.view.backgroundColor = UIColor.gray

        originalPoint = self.view.center

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.beingDragged))
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)

        //生成question
        let qts = [QuestionType.MF,QuestionType.FM,QuestionType.Fill]
        for(idx,w) in self.words!.enumerated(){
//            self.questions.append(contentsOf: w.createQuestions(types:qts))
        }

//        for (idx,q) in self.questions.enumerated(){
//            if loadedViews.count < bufferSize {
//                let questionView = QuestionView2(frame: self.view.frame,question: self.questions[0])
//                if loadedViews.isEmpty {
//                    self.view.addSubview(questionView)
//                } else {
//                    self.view.insertSubview(questionView, belowSubview: loadedViews.last!)
//                }
//                loadedViews.append(questionView)
//                self.questionView = questionView
//            }
//        }

        let questionView = QuestionView2(frame: self.view.frame,question: self.questions[0])
        loadedViews.append(questionView)
        self.view.addSubview(questionView)
        let questionView2 = QuestionView2(frame: self.view.frame,question: self.questions[1])
        loadedViews.append(questionView)
        self.view.insertSubview(questionView2, belowSubview: loadedViews.last!)
        self.questionView = questionView
    }
}

extension LearnTestViewController3: UIGestureRecognizerDelegate {

    /*
     * Gesture methods
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /*
     * Gesture methods
     */
    @objc fileprivate func beingDragged(_ gestureRecognizer: UIPanGestureRecognizer) {

        xCenter = gestureRecognizer.translation(in: self.questionView!).x
        yCenter = gestureRecognizer.translation(in: self.questionView!).y

        switch gestureRecognizer.state {
                // Keep swiping
        case .began:
            print("begin")
            break;
                //in the middle of a swipe
        case .changed:
            print(xCenter,yCenter,theresoldMargin)

            self.questionView!.center = CGPoint(x: originalPoint.x + xCenter, y: originalPoint.y + yCenter)
//            let transforms = CGAffineTransform(rotationAngle: rotationAngel)
//            let scaleTransform: CGAffineTransform = transforms.scaledBy(x: scale, y: scale)
//            self.transform = scaleTransform
//            updateOverlay(xCenter)
            break;
                // swipe ended
        case .ended:
            afterSwipeAction()
            print("ended")

//            let finishPoint = CGPoint(x: -self.view.center.x, y: self.view.center.y)
//            UIView.animate(withDuration: 1, animations: {
//                self.questionView!.center = finishPoint
//            }, completion: {(_) in
//                self.questionView!.removeFromSuperview()
//            })

            break;

        case .possible:break
        case .cancelled:break
        case .failed:break
        @unknown default:
            fatalError()
        }
    }

    fileprivate func afterSwipeAction() {

        if xCenter > theresoldMargin {
            cardGoesRight()
        }
        else if xCenter < -theresoldMargin {
            cardGoesLeft()
        }
        else {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: {
                self.questionView!.center = self.originalPoint
//                self.transform = CGAffineTransform(rotationAngle: 0)
//                self.statusImageView.alpha = 0
//                self.overlayImageView.alpha = 0
            })
        }
    }

    func cardGoesRight() {
        let finishPoint = CGPoint(x: self.view.center.x*2, y: self.view.center.y)
        UIView.animate(withDuration: 0.5, animations: {
            self.questionView!.center = finishPoint
        }, completion: {(_) in
            self.questionView!.removeFromSuperview()
        })

        removeCardAndAddNewCard()
    }

    /*
     * Card goes left method
     */
    func cardGoesLeft() {
        let finishPoint = CGPoint(x: -self.view.center.x*2, y: self.view.center.y)
        UIView.animate(withDuration: 0.5, animations: {
            self.questionView!.center = finishPoint
        }, completion: {(_) in
            self.questionView!.removeFromSuperview()
        })

        removeCardAndAddNewCard()
    }

    func removeCardAndAddNewCard(){

        curr_index += 1
        let card = loadedViews.first!
        loadedViews.remove(at: 0)

        self.questionView = loadedViews[0]
//
//        if (curr_index + loadedViews.count) < self.questions.count {
//            let tinderCard = QuestionView2(frame:self.view.frame,question:self.questions[curr_index])
//            self.view.insertSubview(tinderCard, belowSubview: loadedViews.last!)
//            loadedViews.append(tinderCard)
//            self.questionView = tinderCard
//        }
    }
}
