//
// Created by ac on 2019-07-05.
// Copyright (c) 2019 Fin. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension UIViewController{
    func confirm(title:String,message:String,okHandler:@escaping (UIAlertAction)->Void){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "确定", style: .default, handler: okHandler))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        present(controller, animated: true, completion: nil)
    }
    
    func customNavBackButton(backAction:Selector?){
        var menuButton:UIBarButtonItem
        if backAction != nil{
            menuButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: backAction)
        }
        else{
            menuButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(defaultBack))
        }
        let bimg = UIImage(from: .segoeMDL2, code: "ChevronLeft", textColor: .black, backgroundColor: .clear, size: CGSize(width: 20, height: 20))
        menuButton.image = bimg
        menuButton.tintColor = .black
        menuButton.imageInsets = UIEdgeInsetsMake(0, -12, 0, 0)
        
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func defaultBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func isShowing()->Bool{
        return (self.isViewLoaded && ((self.view?.window) != nil));
    }
    
//    func setupTranslationMenu(langGetter:@escaping () ->Int, formGetter: @escaping ()->String) {
//        let sch = { (sender: UIMenuItem)-> Void in
//            let lang = langGetter()
//            let md = formGetter()
//            var request = DictionaryApi.provider.requestAPI(.searchWord(lang: lang, form: md))
//            if(sender.title == "Google"){
//                request = OtherApi.provider.requestAPI(.googleTranslate(text: md))
//            }
//
//            SVProgressHUD.show(withStatus: "正在查询")
//
//            _ = request
//                .mapResponseToObj(WordSearchModel.self)
//                .subscribe(onNext: { (response) in
//                    SVProgressHUD.dismiss()
//
//                    let popUpView = SearchPopUpView()
//                    popUpView.setInfo(word: response.word!)
//                    let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//                    alertView.setValue(popUpView, forKey: "contentViewController")
//
//                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alertView, animated: true, completion: nil)
//
//                }, onError: { (error) in
//                    SVProgressHUD.showError(withStatus: error.rawString())
//                })
//        }
        
//        let mi_ava = UIMenuItem(title:"AVA", action: Selector("sch"))
//        let mi_ggl = UIMenuItem(title:"Google", action:Selector("sch"))
//        UIMenuController.shared.menuItems = [mi_ava,mi_ggl]
//        UIMenuController.shared.update()
//    }
}
