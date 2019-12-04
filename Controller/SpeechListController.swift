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


class SpeechListController: UIViewController {
    var speechList:Array<ArticleModel>?
    
    var currentPage = 0
    
    fileprivate lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        regClass(tableView, cell: SpeechListTableViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.topItem?.title = "会话"
        
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
    }
    
    func refreshPage(){
        self.tableView.mj_header.beginRefreshing();
    }
    func refresh(){
        //如果有上拉加载更多 正在执行，则取消它
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //获取脚本列表
        _ = SpeechApi.provider
            .requestAPI(.getSpeechList())
            .mapResponseToObjArray(ArticleModel.self)
            .subscribe(onNext: { (response) in
                self.speechList = response
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
        if let count = self.speechList?.count , count <= 0{
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        
        //获取下一页词书
        self.tableView.mj_footer.endRefreshing()
        
    }
}


//MARK: - TableViewDataSource
extension SpeechListController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.speechList {
            return list.count;
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.speechList![indexPath.row]
        
        return SpeechListTableViewCell().getHeight(item)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: SpeechListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.speechList![indexPath.row]);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.speechList![indexPath.row]
        
        let speechController = SpeechController()
        speechController.article = item
        speechController.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(speechController, animated: true)
    }
}
