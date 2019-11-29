//
//  UserBookViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit

import Alamofire
import AlamofireObjectMapper

import Ji
import MJRefresh

import SVProgressHUD


class UserWordStatController: UIViewController {
    var statList:Array<UserWordStatModel>?
    var currentPage = 0
    var pickerViewVc:UIViewController!
    var pickerView:UIPickerView!
    var pickerNums:[Int] = [5,10,15,20,25,30,35,40,45,50]
    
    var actionFloatView: UserBookRightFloatView!
    
    fileprivate lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        regClass(tableView, cell: UserWordStatListTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationItem()

        self.edgesForExtendedLayout = []
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 100)
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        pickerViewVc = vc
        pickerView.selectRow(3,inComponent:0,animated:true)

        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
        //Init ActionFloatView
        self.actionFloatView = UserBookRightFloatView()
        self.actionFloatView.delegate = self
        self.view.addSubview(self.actionFloatView)
        self.actionFloatView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.refreshPage()

        let footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
        })
        footer?.centerOffset = -4
        self.tableView.mj_footer = footer
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.actionFloatView.hide(true)
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let names = ["学习", "复习"]
                for name in names {
                    let action = UIAlertAction(title: name, style: .default) { (action) in

                        if name == "学习" {
                            self.learnNew(indexPath.row)
                        }
                        else {
                            self.reviewOld(indexPath.row)
                        }
                    }
                    controller.addAction(action)
                }
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                controller.addAction(cancelAction)

                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func setupNavigationItem(){
        self.navigationController!.navigationBar.topItem?.title = "词汇"
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.tintColor = .black
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        let bimg = UIImage(from: .segoeMDL2, code: "DictionaryAdd", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        rightButton.setImage(bimg.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(UserWordStatController.rightClick), for: .touchUpInside)
        
//        self.navigationItem.rightButtonAction(TSAsset.Barbuttonicon_add.image) { () -> Void in
//            self.actionFloatView.hide(!self.actionFloatView.isHidden)
//        }

    }
    
    //打开公共词书页面，选择词书
    @objc func rightClick(){
//        let publicBookController = PublicBookViewController()
//        publicBookController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(publicBookController, animated: true)
        
        self.actionFloatView.hide(!self.actionFloatView.isHidden)
    }
    
    func refreshPage(){
        self.tableView.mj_header.beginRefreshing();
    }
    func refresh(){
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //获取用y户词汇信息
        _ = DictionaryApi.provider
                .requestAPI(.getMyWords)
                .mapResponseToObjArray(UserWordStatModel.self)
                .subscribe(onNext: { (response) in
                    self.statList = response
                    self.tableView.reloadData()

                    //判断标签是否能加载下一页, 不能就提示下
                    let refreshFooter = self.tableView.mj_footer as! V2RefreshFooter

                    refreshFooter.noMoreDataStateString = nil
                    refreshFooter.resetNoMoreData()

                    //重置page
                    self.currentPage = 0
                    self.tableView.mj_header.endRefreshing()

                }, onError: { (error) in
                    SVProgressHUD.showError(withStatus: error.rawString())
                    self.tableView.mj_header.endRefreshing()
                })

    }
    
    func getNextPage(){
        if let count = self.statList?.count , count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }

        //获取下一页词书
        self.tableView.mj_footer.endRefreshing()

    }
    
    static var lastLeaveTime = Date()
    @objc func applicationWillEnterForeground(){
        //计算上次离开的时间与当前时间差
        //如果超过2分钟，则自动刷新本页面。
        let interval = -1 * UserWordStatController.lastLeaveTime.timeIntervalSinceNow
        if interval > 120 {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    @objc func applicationDidEnterBackground(){
        UserWordStatController.lastLeaveTime = Date()
    }
}


//MARK: - TableViewDataSource
extension UserWordStatController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.statList {
            return list.count;
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.statList![indexPath.row]

        return UserWordStatListTableViewCell().getHeight(item)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: UserWordStatListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.statList![indexPath.row]);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.statList![indexPath.row]

        self.selectedRowWithActionSheet(indexPath)
    }

    func selectedRowWithActionSheet(_ indexPath:IndexPath){
        self.tableView.deselectRow(at: indexPath, animated: true);
        
        let wordController = WordListController()
        
        let item = self.statList![indexPath.row]
        wordController.lang = item.lang
        wordController.page_size=20
        wordController.page_index=0
        wordController.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(wordController, animated: true)
    }

    @objc func learnNew(_ row:Int){
        let item = self.statList![row]

        let controller = UIAlertController(title: "选择单词个数", message: nil, preferredStyle: .alert)
        controller.setValue(pickerViewVc, forKey: "contentViewController")

        let okAction = UIAlertAction(title: "确定", style: .default) { (_) in

            let pi = self.pickerView.selectedRow(inComponent: 0)
            let wc = self.pickerNums[pi]

            _ = DictionaryApi.provider
                    .requestAPI(.getNewWords(lang:item.lang,word_count:wc))
                    .mapResponseToObjArray(WordModel.self)
                    .subscribe(onNext: { (response) in

                        if(response.count == 0){
                            SVProgressHUD.showError(withStatus: "没有未学习的新词")
                        }
                        else{
                        let wordController = WordScanViewController(transitionStyle:UIPageViewController.TransitionStyle.scroll, navigationOrientation:UIPageViewController.NavigationOrientation.horizontal)
                            wordController.lang = item.lang
                        wordController.words=response
                        wordController.hidesBottomBarWhenPushed = true

                        self.navigationController?.pushViewController(wordController, animated: true)
                        }

                    }, onError: { (error) in
                        SVProgressHUD.showError(withStatus: error.rawString())

                    })
        }
        controller.addAction(okAction)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    @objc func reviewOld(_ row:Int){
        let item = self.statList![row]

        let controller = UIAlertController(title: "选择单词个数", message: nil, preferredStyle: .alert)
        controller.setValue(pickerViewVc, forKey: "contentViewController")

        let okAction = UIAlertAction(title: "确定", style: .default) { (_) in

            let pi = self.pickerView.selectedRow(inComponent: 0)
            let wc = self.pickerNums[pi]

            _ = DictionaryApi.provider
                    .requestAPI(.reviewOldWords(lang: item.lang, word_count: wc))
                    .mapResponseToObjArray(WordModel.self)
                    .subscribe(onNext: { (response) in
                        
                        if(response.count == 0){
                            SVProgressHUD.showError(withStatus: "没有需要复习的词")
                        }
                        else{
                            let wordController = LearnTestViewController(lang: item.lang, words: response)
                        wordController.hidesBottomBarWhenPushed = true

                        self.navigationController?.pushViewController(wordController, animated: true)
                        }

                    }, onError: { (error) in
                        SVProgressHUD.showError(withStatus: error.rawString())
                    })
        }

        controller.addAction(okAction)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)

    }
}

extension UserWordStatController:UIPickerViewDelegate, UIPickerViewDataSource{

    //设置选择框的列数为3列,继承于UIPickerViewDataSource协议
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    //设置选择框的行数为9行，继承于UIPickerViewDataSource协议
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return self.pickerNums.count
    }

    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return String(pickerNums[row])
    }
}

extension UserWordStatController: UserBookFloatViewDelegate {
    func floatViewTapItemIndex(_ type: UserBookFloatViewItemType) {
        switch type {
        case .publicBook:
//            let publicBookController = PublicBookViewController()
//            publicBookController.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(publicBookController, animated: true)
            break
        case .customDefine:
//            let cController = CreateUserBookController()
//            cController.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(cController, animated: true)
            break
        default:
            break
        }
    }
}
