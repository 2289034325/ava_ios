//
//  ArticleController2.swift
//  Speech
//
//  Created by 菜白 on 2018/8/11.
//  Copyright © 2018年 Freedom. All rights reserved.
//

import UIKit
import AVKit

import SnapKit

import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import MJRefresh

import SVProgressHUD

class SampleArticleController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    var article_id: String?
    var article = WritingArticleModel(map: Map(mappingType: .fromJSON, JSON: [:]))
    var splits = [ParagraphSplitModel]()
    var histories = [WritingHistoryModel]()
        
    let tableView = UITableView()
    
    func setupCustomMenu() {
        let mi_ava = UIMenuItem(title:"AVA", action:#selector(searchAVA))
        let mi_ggl = UIMenuItem(title:"Google", action:#selector(searchGGL))
        UIMenuController.shared.menuItems = [mi_ava,mi_ggl]
        UIMenuController.shared.update()
    }
    
    @objc func searchAVA(_ sender:Any?){
        let md = selectionText!
        SVProgressHUD.show(withStatus: "正在查询")
        
        _ = DictionaryApi.provider
            .requestAPI(.searchWord(lang: article!.lang, form: md))
            .mapResponseToObj(WordSearchModel.self)
            .subscribe(onNext: { (response) in
                SVProgressHUD.dismiss()
                
                let popUpView = SearchPopUpView()
                popUpView.setInfo(word: response.word!)
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alertView.setValue(popUpView, forKey: "contentViewController")
                
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertView, animated: true, completion: nil)
                
            }, onError: { (error) in
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    @objc func searchGGL(_ sender:Any?){
        let md = selectionText!
        SVProgressHUD.show(withStatus: "正在查询")
        
        _ = OtherApi.provider
            .requestAPI(.googleTranslate(text: md))
            .mapResponseToObj(GoogleTransModel.self)
            .subscribe(onNext: { (response) in
                SVProgressHUD.dismiss()
                
                let popUpView = SearchPopUpView()
                let text = response.getAllTrans()                
                popUpView.setInfo(trans: text)
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alertView.setValue(popUpView, forKey: "contentViewController")
                
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertView, animated: true, completion: nil)
                
            }, onError: { (error) in
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    var selectionText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.dataSource = self
        tableView.delegate = self
        
        self.edgesForExtendedLayout = []
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        loadArticle()
        
        setupCustomMenu()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.splits.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let hv = UIView()
        hv.backgroundColor = V2EXColor.colors.v2_backgroundColor;
        let htl = UILabel()
        htl.font = UIFont.boldSystemFont(ofSize: 17)
        htl.numberOfLines = 0
        htl.lineBreakMode = .byCharWrapping
        htl.text = "P\(self.splits[section].paragraph!.index)-S\(self.splits[section].index+1)"
        hv.addSubview(htl)
        htl.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(hv)
            make.left.equalTo(hv).offset(5)
            make.right.equalTo(hv).offset(-5)
        }
        
//        let splitDbTap = UITapGestureRecognizer(target: self, action: #selector(SpeechController.headerDbTapAction))
//        splitDbTap.numberOfTapsRequired = 2
//
//        hv.isUserInteractionEnabled = true
//        hv.addGestureRecognizer(splitDbTap)
//
//        hv.accessibilityElements = [self.article!.paragraphs[section]]
        
        return hv
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 自动适配高度!!!
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell()
        
//        let paragraph = self.article!.paragraphs[indexPath.section]
        let split = self.splits[indexPath.row]
        
        let textView = MyTextView()
        
        let splitDbTap = UITapGestureRecognizer(target: self, action: #selector(SampleArticleController.splitDbTapAction))
        splitDbTap.numberOfTapsRequired = 2
        textView.isUserInteractionEnabled = true
        textView.addGestureRecognizer(splitDbTap)
        
        // 不加isScrollEnabled，文字不显示!!!
        textView.isEditable = false;
        textView.isScrollEnabled = false
        textView.returnKeyType = UIReturnKeyType.done
        textView.isSelectable = true
        textView.delegate = self
        textView.font = v2Font(18)
        textView.textContainer.lineBreakMode = .byWordWrapping
//        let startIndex = split.paragraph!.text.index(split.paragraph!.text.startIndex, offsetBy: split.start_index)
//        let endIndex =  split.paragraph!.text.index(split.paragraph!.text.startIndex, offsetBy: split.end_index+1)
//        textView.text = String(split.paragraph!.text[startIndex ..< endIndex])
        textView.text = split.getText()
        textView.accessibilityElements = [split]
        
        cell.contentView.addSubview(textView)
        textView.snp.makeConstraints{ (make) -> Void in
            // top 和 bottom约束必须都有，否则textView不能等自动适配高度!!!
            make.top.bottom.equalTo(cell.contentView)
            make.left.equalTo(cell.contentView).offset(5)
            make.right.equalTo(cell.contentView).offset(-5)
        }
        
        return cell
    }
    
    @objc func splitDbTapAction(sender:UITapGestureRecognizer) {
        
        let lbl = sender.view as! UITextView
        let split = lbl.accessibilityElements![0] as! ParagraphSplitModel
        
        lbl.isEditable = true
        lbl.becomeFirstResponder()
    }
    
    func loadArticle()
    {
        _ = WritingApi.provider
            .requestAPI(.getArticle(article_id: self.article_id!))
            .mapResponseToObj(WritingArticleModel.self)
            .subscribe(onNext: { (response) in
                self.article = response
                // 段落排序
                self.article?.paragraphs.sort(by: { (p1, p2) -> Bool in
                    return p1.index<p2.index
                })
                // 片段排序
                self.article?.paragraphs.forEach({ (p) in
                    p.splits.sort { (s1, s2) -> Bool in
                        return s1.index<s2.index
                    }
                    
                    p.splits.forEach { (s) in
                        s.paragraph = p
                        s.histories = response.histories.filter({ (h) -> Bool in
                            return h.split_id == s.id
                        })
                    }
                })
                
                self.splits.removeAll()
                self.article?.paragraphs.forEach({ (p) in
                    self.splits.append(contentsOf: p.splits)
                })
                
                self.navigationItem.title = response.title
                self.tableView.reloadData()
                
            }, onError: { (error) in
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let split = textView.accessibilityElements![0] as! ParagraphSplitModel
        let ht = WritingHistoryModel(map: Map(mappingType: .fromJSON, JSON: [:]))
        ht?.article_id = self.article_id
        ht?.paragraph_id = split.paragraph?.id
        ht?.split_id = split.id
        ht?.content = textView.text
        ht?.id = UUID().uuidString
        
        SVProgressHUD.show(withStatus: "正在提交...")
        
        // 提交
        _ = WritingApi.provider
            .requestAPI(.submitText(history: ht!))
            .mapResponseToObj(WritingHistoryModel.self)
            .subscribe(onNext: { (response) in
                let atrString = response.getDiffText(font: v2Font(18))
                textView.attributedText = atrString
                
                textView.isEditable = false
                SVProgressHUD.dismiss()
        }, onError: { (error) in
            textView.isEditable = false
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error.rawString())
        })
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //按回车是退出编辑
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if (textView.selectedTextRange != nil){
            self.selectionText = textView.text(in:textView.selectedTextRange!)
        }
    }
    
    
    
    // controller init 垃圾东西!!!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
