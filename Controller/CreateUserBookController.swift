//
//  CreateUserBookController.swift
//  AVA-Swift
//
//  Created by ac on 8/2/19.
//  Copyright © 2019 Fin. All rights reserved.
//

import Foundation
import UIKit
import DropDown
import SnapKit
import SVProgressHUD

class CreateUserBookController: UIViewController{
    
    var selectedLang = 0
    
    var langLbl:MyUITextField={
        let lbl = MyUITextField()
        lbl.font = UIFont.systemFont(ofSize: 17)
        lbl.placeholder = "请选择"
        return lbl
    }()
    
    var langComb:DropDown={
        let cmb = DropDown()
        return cmb
    }()
    
    var bookNameTxb:MyUITextField={
       let txb = MyUITextField()
        txb.font = UIFont.systemFont(ofSize: 17)
        txb.placeholder = "请填写名称"
        return txb
    }()
    
    var descTxb:UITextView={
        let txb = UITextView()
        txb.font = UIFont.systemFont(ofSize: 17)
        return txb
    }()
    
    override func viewDidLoad() {
        self.title = "自定义词书"
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .white
        
        self.view.addSubview(langLbl)
        langLbl.backgroundColor = #colorLiteral(red: 0.8885429886, green: 0.8885429886, blue: 0.8885429886, alpha: 1)
        langLbl.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(50)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.height.equalTo(40)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(langLblTaped(sender:)))
        langLbl.isUserInteractionEnabled = true
        langLbl.addGestureRecognizer(tap)

        self.view.addSubview(bookNameTxb)
        bookNameTxb.backgroundColor = #colorLiteral(red: 0.8885429886, green: 0.8885429886, blue: 0.8885429886, alpha: 1)
        bookNameTxb.snp.makeConstraints { (make) in
            make.top.equalTo(langLbl.snp.bottom).offset(40)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.height.equalTo(40)
        }

        self.view.addSubview(descTxb)
        descTxb.backgroundColor = #colorLiteral(red: 0.8885429886, green: 0.8885429886, blue: 0.8885429886, alpha: 1)
        descTxb.snp.makeConstraints { (make) in
            make.top.equalTo(bookNameTxb.snp.bottom).offset(40)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.height.equalTo(100)
        }

        let saveBtn = UIButton()
//        saveBtn.tintColor = .white
        saveBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5032967925, blue: 1, alpha: 1)
        saveBtn.setTitle("保存", for:.normal)
        self.view.addSubview(saveBtn)
        saveBtn.snp.makeConstraints { (make) in
            make.top.equalTo(descTxb.snp.bottom).offset(40)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.height.equalTo(50)
        }
        saveBtn.addTarget(self, action: #selector(CreateUserBookController.saveUserBook), for: .touchUpInside)

        // The view to which the drop down will appear on
        langComb.anchorView = langLbl
        langComb.direction = .bottom
        langComb.bottomOffset = CGPoint(x: 0, y:(langComb.anchorView?.plainView.bounds.height)!)
        langComb.dataSource = Lang.all.map{l in l.name}
        langComb.selectionAction = { [unowned self] (index: Int, item: String) in
//            print("Selected item: \(item) at index: \(index)")
            let l = Lang.fromName(name: item)!
            self.langLbl.text = item
            self.selectedLang = l.id
        }
        
    }
    
    func saveUserBook(){
        let book = UserBookModel()
        book.lang = selectedLang
        book.name = bookNameTxb.text!
        book.description = descTxb.text
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show(withStatus: "正在提交")
        
        _ = DictionaryApi.provider
            .requestAPI(.saveUserBook(book: book))
            .subscribe(onNext: { (response) in
                SVProgressHUD.setStatus("保存成功，正在返回")
                SVProgressHUD.dismiss(withDelay: 1, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }, onError: { (error) in
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: error.rawString())
            })
    }
    
    @objc func langLblTaped(sender:UITapGestureRecognizer) {
        langComb.show()
    }
}
