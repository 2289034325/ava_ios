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
    var selectedIndex = 0
    lazy var optionAlert:UIAlertController={
        let controller = UIAlertController(title: "操作", message: "请选择", preferredStyle: .actionSheet)
        let names = ["删除"]
        for name in names {
            let action = UIAlertAction(title: name, style: .default) { (action) in
                
                if name == "删除" {
                    self.deleteBookMark(bookMark: self.bookMarks[self.selectedIndex])
                }
            }
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        return controller
    }()
    
    var bookMarks = [BookMarkModel]()
    
    var currentPage = 0
    
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
        
        regClass(tableView, cell: BookMarkListTableViewCell.self)
        
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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
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
        if self.tableView.mj_footer.isRefreshing {
            self.tableView.mj_footer.endRefreshing()
        }
        
        //获取用户书签列表
        _ = ReadingApi.provider
            .requestAPI(.bookMarkList)
            .mapResponseToObjArray(BookMarkModel.self)
            .subscribe(onNext: { (response) in
                self.bookMarks = response
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
        self.tableView.mj_footer.endRefreshing()
    }
    
    func editBookMark(bookMark: BookMarkModel) {
        SVProgressHUD.showInfo(withStatus: "正在保存")
        _ = ReadingApi.provider
            .requestAPI(.editBookMark(bookMark))
            .subscribe(onNext: { (response) in
                SVProgressHUD.dismiss()
            }, onError: { (error) in
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    func addBookMark(bookMark: BookMarkModel) {        
        SVProgressHUD.showInfo(withStatus: "正在保存")
        _ = ReadingApi.provider
            .requestAPI(.addBookMark(bookMark))
            .subscribe(onNext: { (response) in
                SVProgressHUD.dismiss()
            }, onError: { (error) in
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    func deleteBookMark(bookMark: BookMarkModel) {
        let controller = UIAlertController(title: "确认", message: "是否确定要删除", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "确定", style: .default) { (_) in
            
            SVProgressHUD.showInfo(withStatus: "正在删除")
            _ = ReadingApi.provider
                .requestAPI(.deleteBookMark(bookMark))
                .subscribe(onNext: { (response) in
                    SVProgressHUD.dismiss()
                }, onError: { (error) in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: error.rawString())
                })
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
}


//MARK: - TableViewDataSource
extension BookMarkListController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.bookMarks[indexPath.row]
        
        return BookMarkListTableViewCell().getHeight(item)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = getCell(tableView, cell: BookMarkListTableViewCell.self, indexPath: indexPath);
        cell.bind(self.bookMarks[indexPath.row]);
        return cell;
//
////        let cell = UITableViewCell()
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BookMarkListTableViewCell
//
//        let md = bookMarks[indexPath.row]
//        cell.textLabel!.text = md.title
//
//        cell.imageView?.contentMode = .scaleAspectFit
//        cell.imageView?.snp.removeConstraints()
//        cell.imageView?.snp.makeConstraints({ (make) in
//            make.width.equalTo(20)
//            make.height.equalTo(20)
//        })
//
//        if(!md.url.isEmpty) {
//            let url = URL(string: md.url)!
//            let url_str = "\(url.scheme!)://\(url.host!)\(url.port == nil ? "" : ":"+String(url.port!))/favicon.ico"
//            cell.imageView!.fin_setImageWithUrl(URL(string: url_str)!, placeholderImage: placeholder_img, imageModificationClosure: fin_defaultImageModification())
//        }
//
//        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let md = bookMarks[indexPath.row]
        
        let brs = ReadingBrowserController()
        brs.initBookMark = md
        brs.delegate = self
        
        brs.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(brs, animated: true)
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.selectedIndex = indexPath.row
                present(optionAlert, animated: true, completion: nil)
            }
        }
    }
}
