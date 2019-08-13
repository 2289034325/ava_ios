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


class BookMarkListController: UIViewController,SaveBookMarkDelegate {
    
    
//    var addBtn:UIButton={
//        let btn = UIButton()
//        let bimg = UIImage(from: .fontAwesome, code: "pluscircle", textColor: #colorLiteral(red: 0, green: 0.5032967925, blue: 1, alpha: 1), backgroundColor: .clear, size: CGSize(width: 40, height: 40))
//        btn.setImage(bimg.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
//        
//        return btn
//    }()
    
    var bookMarks = [BookMarkModel]()
    
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
        // view子控件上下位置问题，这样保证不超过上方的导航条和下方的tabbar!!!
        self.edgesForExtendedLayout = []
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        rightButton.contentMode = .center
        rightButton.tintColor = .black
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        let bimg = UIImage(from: .segoeMDL2, code: "Add", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        rightButton.setImage(bimg.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(BookMarkListController.rightClick), for: .touchUpInside)
        
        self.view.addSubview(self.tableView);
        self.tableView.snp.makeConstraints{ (make) -> Void in
            make.top.right.bottom.left.equalTo(self.view);
        }
        
//        self.view.addSubview(addBtn)
//        addBtn.snp.makeConstraints { (make) in
//            make.right.bottom.equalTo(self.view).offset(-10)
//        }
        
        self.tableView.mj_header = V2RefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
        })
        self.refreshPage()
        
        let footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage()
        })
        footer?.centerOffset = -4
        self.tableView.mj_footer = footer
        
        let bm = BookMarkModel()
        bm.title = "HK News"
        bm.url = "http://192.168.1.225:8090/display/~caiyongjie/News+Test"
        bookMarks.append(bm)
        
        let bm2 = BookMarkModel()
        bm2.title = "163 News"
        bm2.url = "https://www.163.com"
        bookMarks.append(bm2)
    }
    
    @objc func rightClick(){
        let bController = ReadingBrowserController()
        bController.hidesBottomBarWhenPushed = true
        bController.delegate = self
        
        self.navigationController?.pushViewController(bController, animated: true)
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
    
    func editBookMark(bookMark: BookMarkModel) {
        bookMarks.forEach { (bm) in
            if bm.id == bookMark.id{
                bm.url = bookMark.url
            }
        }
        tableView.reloadData()
    }
    func addBookMark(bookMark: BookMarkModel) {
        bookMarks.append(bookMark)
        tableView.reloadData()
    }
}


//MARK: - TableViewDataSource
extension BookMarkListController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let md = bookMarks[indexPath.row]
        cell.textLabel!.text = md.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let md = bookMarks[indexPath.row]
        
        let brs = ReadingBrowserController()
        brs.initBookMark = md
        brs.delegate = self
        
        brs.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(brs, animated: true)
    }
}
