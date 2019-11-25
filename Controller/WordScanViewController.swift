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



class WordScanViewController: UIPageViewController {
    var lang: Int?
    var words = [WordModel]()
    var curr_word_index:Int = 0
    var title_panel:UIView?



    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化界面
        self.navigationItem.title = "1/\(self.words.count)"
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.tintColor = .black
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        let bimg = UIImage(from: .segoeMDL2, code: "MultiSelectMirrored", textColor: .black, backgroundColor: .clear, size: CGSize(width: 30, height: 30))
        rightButton.setImage(bimg.withRenderingMode(.alwaysTemplate), for: UIControlState())
        rightButton.addTarget(self, action: #selector(WordScanViewController.rightClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        customNavBackButton(backAction: nil)

        self.hideKeyboardWhenTappedAround()
        delegate=self
        dataSource=self

        let word = words[0]
        let wv = WordViewController()
        wv.word = word
        wv.index = 0
        self.setViewControllers([wv], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    @objc func swipG(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .recognized {
            print("swiped!")
        }
    }

    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen edge swiped!")
        }
    }

}

//extension WordScanViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
////        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
//////            navigationController?.popViewController(animated: true)
////        }
//        return false
//    }
//}

extension WordScanViewController: UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.words.count
    }

//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
//
//    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //如果是第0页，返回nil
        let ctr = viewController as! WordViewController
        self.navigationItem.title = "\(ctr.index!+1)/\(self.words.count)"
        if ctr.index == 0 {
            return nil
        }

//        print("before:\(curr_word_index)")
//
//        curr_word_index -= 1



        let wv = WordViewController()
        wv.word = words[ctr.index!-1]
        wv.index = ctr.index!-1

        return wv
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ctr = viewController as! WordViewController
        self.navigationItem.title = "\(ctr.index!+1)/\(self.words.count)"
        if ctr.index == words.count-1 {
            return nil
        }

//        print("after:\(curr_word_index)")

//        curr_word_index += 1


        let wv = WordViewController()
        wv.word = words[ctr.index!+1]
        wv.index = ctr.index!+1

        return wv
    }

}

extension WordScanViewController {

    func setupView(){
        let word = self.words[curr_word_index]

        self.navigationItem.title = "1/\(self.words.count)"



        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        rightButton.setImage(UIImage.imageUsedTemplateMode("check")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        rightButton.addTarget(self, action: #selector(WordScanViewController.rightClick), for: .touchUpInside)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)


        self.hideKeyboardWhenTappedAround()
    }

    //开始测试
    @objc func rightClick(){
//        let testController = LearnTestViewController(transitionStyle:UIPageViewController.TransitionStyle.scroll, navigationOrientation:UIPageViewController.NavigationOrientation.horizontal)
        let testController = LearnTestViewController(lang:self.lang!,words:self.words)
        testController.hidesBottomBarWhenPushed = true
        testController.refrenceView = "wordscan"
        self.navigationController?.pushViewController(testController, animated: true)
    }
}
