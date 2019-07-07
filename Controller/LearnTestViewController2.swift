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


class LearnTestViewController2: UIViewController {

    var book:BookModel?
    var words:[WordModel]?
    var questions=[QuestionModel]()


    var viewContainer:UIView?// = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.view.backgroundColor = UIColor.gray
        viewContainer = UIView(frame: self.view.frame)

        self.view.addSubview(viewContainer!)
//        viewContainer.snp.makeConstraints{ (make) -> Void in
//            make.left.top.right.equalTo(self.view)
//            make.bottom.equalTo(self.view).offset(200)
//        }

        //生成question
        let qts = [QuestionType.MF,QuestionType.FM,QuestionType.Fill]
        for(idx,w) in self.words!.enumerated(){
            self.questions.append(contentsOf: w.createQuestions(types:qts))
        }

        // Dynamically create view for each tinder card
        let contentView: (Int, CGRect, QuestionModel) -> (UIView) = { (index: Int ,frame: CGRect , userModel: QuestionModel) -> (UIView) in
            let customView = QuestionView(frame: frame,question: self.questions[0])
//            customView.question = self.questions[0]
            return customView
//            return self.programticViewForOverlay(frame: frame, userModel: userModel)
        }

        let swipeView = TinderSwipeView<QuestionModel>(frame: viewContainer!.bounds, contentView: contentView)
        viewContainer!.addSubview(swipeView)
//        swipeView.snp.makeConstraints{ (make) -> Void in
//            make.left.top.right.bottom.equalTo(viewContainer)
//        }

        swipeView.showTinderCards(with: questions ,isDummyShow: true)
    }

    private func programticViewForOverlay(frame:CGRect, userModel:QuestionModel) -> UIView{

        let containerView = UIView(frame: frame)

        let backGroundImageView = UIImageView(frame:containerView.bounds)
        backGroundImageView.image = UIImage(named:"user")
        backGroundImageView.contentMode = .scaleAspectFill
        backGroundImageView.clipsToBounds = true;
        containerView.addSubview(backGroundImageView)

        let profileImageView = UIImageView(frame:CGRect(x: 25, y: frame.size.height - 80, width: 60, height: 60))
        profileImageView.image =  UIImage(named:"book")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        containerView.addSubview(profileImageView)

        let labelText = UILabel(frame:CGRect(x: 90, y: frame.size.height - 80, width: frame.size.width - 100, height: 60))
//        labelText.attributedText = self.attributeStringForModel(userModel: userModel)
        labelText.numberOfLines = 2
        containerView.addSubview(labelText)

        return containerView
    }
}

extension LearnTestViewController2 : TinderSwipeViewDelegate{

    func dummyAnimationDone() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
//            self.viewNavigation.alpha = 1.0
        }, completion: nil)
        print("Watch out shake action")
    }

    func didSelectCard(model: Any) {
        print("Selected card")
    }

    func fallbackCard(model: Any) {
//        emojiView.rateValue =  2.5
        let userModel = model as! QuestionModel
        print("Cancelling \(userModel.sentence!.word!)")
    }

    func cardGoesLeft(model: Any) {
//        emojiView.rateValue =  2.5
        let userModel = model as! QuestionModel
        print("Watchout Left \(userModel.sentence!.word!)")
    }

    func cardGoesRight(model : Any) {
//        emojiView.rateValue =  2.5
        let userModel = model as! QuestionModel
        print("Watchout Right \(userModel.sentence!.word!)")
    }

    func undoCardsDone(model: Any) {
//        emojiView.rateValue =  2.5
        let userModel = model as! QuestionModel
        print("Reverting done \(userModel.sentence!.word!)")
    }

    func endOfCardsReached() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
//            self.viewNavigation.alpha = 0.0
        }, completion: nil)
        print("End of all cards")
    }

    func currentCardStatus(card object: Any, distance: CGFloat) {
        if distance == 0 {
//            emojiView.rateValue =  2.5
        }else{
            let value = Float(min(abs(distance/100), 1.0) * 5)
            let sorted = distance > 0  ? 2.5 + (value * 5) / 10  : 2.5 - (value * 5) / 10
//            emojiView.rateValue =  sorted
        }
        print(distance)
    }


}

extension UIView {

    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }

    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
}
