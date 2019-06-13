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


class UserBookViewController: UIViewController {
    var bookList:Array<BookModel>?
    var currentPage = 0
    
    fileprivate lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        regClass(tableView, cell: UserBookListTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Books"
        self.setupNavigationItem()
        
        //监听程序即将进入前台运行、进入后台休眠 事件
//        NotificationCenter.default.addObserver(self, selector: #selector(UserBookViewController.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(UserBookViewController.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
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
        
        self.themeChangedHandler = {[weak self] (style) -> Void in
            self?.tableView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        V2Client.sharedInstance.drawerController?.openDrawerGestureModeMask = .panningCenterView
    }
    override func viewWillDisappear(_ animated: Bool) {
        V2Client.sharedInstance.drawerController?.openDrawerGestureModeMask = []
    }
    func setupNavigationItem(){
        let leftButton = NotificationMenuButton()
        leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        leftButton.addTarget(self, action: #selector(UserBookViewController.leftClick), for: .touchUpInside)
        
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        rightButton.setImage(UIImage.imageUsedTemplateMode("ic_more_horiz_36pt")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(UserBookViewController.rightClick), for: .touchUpInside)

    }
    @objc func leftClick(){
        V2Client.sharedInstance.drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
    }
    //打开公共词书页面，选择词书
    @objc func rightClick(){

//        V2Client.sharedInstance.drawerController?.toggleRightDrawerSide(animated: true, completion: nil)
    }
    
    func refreshPage(){
        self.tableView.mj_header.beginRefreshing();

//        V2EXSettings.sharedInstance[kHomeTab] = tab
//        self.tableView.mj_header.endRefreshing();
    }
    func refresh(){
        
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //获取用户词书列表
        _ = DictionaryApi.provider
                .requestAPI(.getMyBooks())
                .mapResponseToObjArray(BookModel.self)
                .subscribe(onNext: { (response) in
                    self.bookList = response
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
        if let count = self.bookList?.count , count <= 0{
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
        let interval = -1 * UserBookViewController.lastLeaveTime.timeIntervalSinceNow
        if interval > 120 {
            self.tableView.mj_header.beginRefreshing()
        }
    }
    @objc func applicationDidEnterBackground(){
        UserBookViewController.lastLeaveTime = Date()
    }
}


//MARK: - TableViewDataSource
extension UserBookViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.bookList {
            return list.count;
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.bookList![indexPath.row]
//        let titleHeight = item.progressLabel?.textBoundingRect.size.height ?? 0
        let progressLabelHeight = 15
        //          上间隔   头像高度  头像下间隔          进度高度        标题下间隔 cell间隔
        let height = 12    +  35     +  12      + progressLabelHeight   + 12      + 8

        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: UserBookListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.bookList![indexPath.row]);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.bookList![indexPath.row]
        
//        if let id = item.id {
//            let topicDetailController = TopicDetailViewController();
//            topicDetailController.topicId = id ;
//            topicDetailController.ignoreTopicHandler = {[weak self] (topicId) in
//                self?.perform(#selector(UserBookViewController.ignoreTopicHandler(_:)), with: topicId, afterDelay: 0.6)
//            }
//            self.navigationController?.pushViewController(topicDetailController, animated: true)
//            tableView .deselectRow(at: indexPath, animated: true);
//        }
    }
    
    @objc func ignoreTopicHandler(_ id:String) {
        let index = self.bookList?.index(where: {$0.id == id })
        if index == nil {
            return
        }
        
        //看当前忽略的cell 是否在可视列表里
        let indexPaths = self.tableView.indexPathsForVisibleRows
        let visibleIndex =  indexPaths?.index(where: {($0 as IndexPath).row == index})
        
        self.bookList?.remove(at: index!)
        //如果不在可视列表，则直接reloadData 就可以
        if visibleIndex == nil {
            self.tableView.reloadData()
            return
        }
        
        //如果在可视列表，则动画删除它
        self.tableView.beginUpdates()
        
        self.tableView.deleteRows(at: [IndexPath(row: index!, section: 0)], with: .fade)
        
        self.tableView.endUpdates()
        

    }
}
