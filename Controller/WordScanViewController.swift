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
    var book:BookModel?
    var words:[WordModel]?
    var curr_word_index:Int = 0
    var title_panel:UIView?



    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
//        self.navigationController?.barHideOnSwipeGestureRecognizer.isEnabled = false
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

//        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
//        edgePan.edges = .left
//
//        view.addGestureRecognizer(edgePan)
//
//        let swipeG = UISwipeGestureRecognizer(target: self, action: #selector(swipG))

        //初始化界面
        self.setupView()

        delegate=self
        dataSource=self

        let word = words![0]
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
        return self.words!.count
    }

//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
//
//    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //如果是第0页，返回nil
        let ctr = viewController as! WordViewController
        self.navigationItem.title = "\(ctr.index!+1)/\(self.words!.count)"
        if ctr.index == 0 {
            return nil
        }

//        print("before:\(curr_word_index)")
//
//        curr_word_index -= 1



        let wv = WordViewController()
        wv.word = words![ctr.index!-1]
        wv.index = ctr.index!-1

        return wv
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ctr = viewController as! WordViewController
        self.navigationItem.title = "\(ctr.index!+1)/\(self.words!.count)"
        if ctr.index == words!.count-1 {
            return nil
        }

//        print("after:\(curr_word_index)")

//        curr_word_index += 1


        let wv = WordViewController()
        wv.word = words![ctr.index!+1]
        wv.index = ctr.index!+1

        return wv
    }

}

extension WordScanViewController {

    func setupView(){
        let word = self.words![curr_word_index]

//        self.navigationController?.navigationItem.title = "1/20"
        self.navigationItem.title = "1/\(self.words!.count)"
//        self.navigationItem.leftItemsSupplementBackButton = true



        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        rightButton.setImage(UIImage.imageUsedTemplateMode("check")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        rightButton.addTarget(self, action: #selector(WordScanViewController.rightClick), for: .touchUpInside)

//        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)

//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: rightButton)

//        self.view.addSubview(tableView)
//        self.tableView.snp.makeConstraints{ (make) -> Void in
//            make.top.right.bottom.left.equalTo(self.view);
//        }
//        self.edgesForExtendedLayout = [];

        self.hideKeyboardWhenTappedAround()
//

//        // 用UIView，上方会被navigationbar挡住
//        // 因为UIView似乎是从屏幕左上方开始布局，不管是否有navigationbar
//        // UIScrollView是自动从navigationbar的下面开始
//        // 也可以设置 self.edgesForExtendedLayout = []
//        let contentView = UIScrollView()
//        self.view.addSubview(contentView);
//        contentView.snp.makeConstraints{ (make) -> Void in
//            make.top.right.bottom.left.equalTo(self.view);
//        }
//
//        let spellLabel = UILabel()
//        spellLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)!;
//        spellLabel.text = word.spell
//        contentView.addSubview(spellLabel);
//        spellLabel.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(contentView)
//            make.left.equalTo(contentView).offset(5)
//        }
//
//        let pronLabel = UILabel()
//        pronLabel.text = "[\(word.pronounce!)]"
//        pronLabel.font = v2Font(12)
//        contentView.addSubview(pronLabel);
//        pronLabel.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(spellLabel.snp.bottom)
//            make.left.equalTo(spellLabel.snp.left)
//        }
//
//        var pronImage: UIImageView = {
//            let imageview = UIImageView(image: UIImage(named: "sound")?.withRenderingMode(.alwaysTemplate))
//            imageview.tintColor = UIColor.blue
//            imageview.contentMode = .scaleAspectFit
//
//            return imageview
//        }()
//        contentView.addSubview(pronImage);
//        pronImage.snp.makeConstraints{ (make) -> Void in
//            make.centerY.equalTo(pronLabel);
//            make.width.height.equalTo(12);
//            make.left.equalTo(pronLabel.snp.right).offset(2);
//        }
//
//        let meaningLabel = UILabel()
//        meaningLabel.numberOfLines = 0
//        meaningLabel.text = word.meaning!
//        meaningLabel.font = v2Font(12)
//        contentView.addSubview(meaningLabel);
//        meaningLabel.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(pronLabel.snp.bottom).offset(5)
//            make.left.equalTo(pronLabel.snp.left)
//        }
    }

    //开始测试
    @objc func rightClick(){
//        let testController = LearnTestViewController(transitionStyle:UIPageViewController.TransitionStyle.scroll, navigationOrientation:UIPageViewController.NavigationOrientation.horizontal)
        let testController = LearnTestViewController2()
        testController.hidesBottomBarWhenPushed = true
        testController.book = self.book
        testController.words = self.words
        self.navigationController?.pushViewController(testController, animated: true)
    }
}
