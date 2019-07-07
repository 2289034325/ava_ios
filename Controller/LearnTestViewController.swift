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



class LearnTestViewController: UIPageViewController {
    var book:BookModel?
    var words:[WordModel]?
    var record:LearnRecordModel?
    var questions=[QuestionModel]()
    var curr_q_index:Int = 0

    var title_panel:UIView?


    override func viewDidLoad() {
        super.viewDidLoad()


        self.edgesForExtendedLayout = []


        self.hideKeyboardWhenTappedAround()

        self.record = LearnRecordModel()
        record!.book_id = self.book!.id
        record!.word_count = self.words!.count
        record!.start_time = Date()
        record!.answer_times = 0
        record!.wrong_times = 0
        record!.detail = []

        //生成question
        let qts = [QuestionType.MF,QuestionType.FM,QuestionType.Fill]
        for(idx,w) in self.words!.enumerated(){
            self.questions.append(contentsOf: w.createQuestions(types:qts))
        }

        self.navigationItem.title = "1/\(self.questions.count)"

        delegate=self
        dataSource=self

        let question = questions[0]
        let qv = QuestionViewController()
        qv.question = question
        qv.index = 0
        self.setViewControllers([qv], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
    }

    @objc func backAction(){
        //如果未测试完，是否确认强制推出
        for (idx, ele) in self.questions.enumerated() {
            if ele.pass != true{
                confirm(title:"确认",message:"测试未完成，是否确定要推出？"){(_) in
                    self.navigationController?.popViewController(animated: true)
                }
            }

            break
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
}

extension LearnTestViewController: UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.words!.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //如果是第0页，返回nil
        let ctr = viewController as! QuestionViewController
        self.navigationItem.title = "\(ctr.index!+1)/\(self.questions.count)"
        if ctr.index == 0 {
            return nil
        }


        let wv = QuestionViewController()
        wv.question = questions[ctr.index!-1]
        wv.index = ctr.index!-1

        return wv
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ctr = viewController as! QuestionViewController
        self.navigationItem.title = "\(ctr.index!+1)/\(self.questions.count)"
        if ctr.index == questions.count-1 {
            return nil
        }


        let wv = QuestionViewController()
        wv.question = questions[ctr.index!+1]
        wv.index = ctr.index!+1

        return wv
    }

}
