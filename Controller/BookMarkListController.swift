//
//  PublicBookViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/8/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AlamofireObjectMapper
import MJRefresh
import SVProgressHUD
import YYText
import SafariServices
import SwiftWebVC


class BookMarkListController: UIViewController {
    
    fileprivate lazy var tableView: UITableView  = {
        let tableView = UITableView()
        tableView.cancelEstimatedHeight()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "书签"
        self.navigationController!.navigationBar.topItem?.title = "书签"
        
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
//
//        self.tableView.mj_header.endRefreshing()
    }
    func refresh(){
        //如果有上拉加载更多 正在执行，则取消它
//        if self.tableView.mj_footer.isRefreshing {
//            self.tableView.mj_footer.endRefreshing()
//        }
        
        self.tableView.mj_header.endRefreshing()
    }
    
    func getNextPage(){
        self.tableView.mj_footer.endRefreshing()
        
    }
}


//MARK: - TableViewDataSource
extension BookMarkListController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel!.text = "CNN"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let brs = ReadingBrowserController()
        brs.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(brs, animated: true)
    }
}
