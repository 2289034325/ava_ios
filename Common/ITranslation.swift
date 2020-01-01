//
//  ITranslation.swift
//  AVA-Swift
//
//  Created by ac on 1/1/20.
//  Copyright © 2020 Fin. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

protocol ITranslation: class {
//    func getLang()->Int
//    func getForm()->String
    func avaSearch(_ sender: UIMenuController)
    func gglSearch(_ sender: UIMenuController)
}

extension ITranslation where Self :UIViewController{
//    func avaSearch(_ sender:Any?){
//        search("AVA",lang: self.getLang(),form: self.getForm())
//    }
//
//    func gglSearch(_ sender:Any?){
//        search("Google",lang: self.getLang(),form: self.getForm())
//    }
    
    func search(_ type:String, lang:Int, form:String){
        let lang = lang
        let md = form
        if(type == "AVA"){
            _ = DictionaryApi.provider
            .requestAPI(.searchWord(lang: lang, form: md))
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
        else if(type == "Google"){
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
    }
    
    func setupTranslationMenu() {
        let mi_ava = UIMenuItem(title:"AVA", action:Selector("avaSearch:"))
        let mi_ggl = UIMenuItem(title:"Google", action:Selector("gglSearch:"))
        UIMenuController.shared.menuItems = [mi_ava,mi_ggl]
        UIMenuController.shared.update()
    }
}

//class TranslationMenu : UIViewController {
//    
//    func setupTranslationMenu() {
//        let mi_ava = UIMenuItem(title:"AVA", action:Selector("search(_:)"))
//        let mi_ggl = UIMenuItem(title:"Google", action:Selector("search"))
//        UIMenuController.shared.menuItems = [mi_ava,mi_ggl]
//        UIMenuController.shared.update()
//    }
//
//    func search(_ sender:Any?){
//        let params = UIPasteboard.general.strings!
//        let lang = Int(params[0])!
//        let md = params[1]
//        SVProgressHUD.show(withStatus: "正在查询")
//
//        _ = DictionaryApi.provider
//            .requestAPI(.searchWord(lang: lang, form: md))
//            .mapResponseToObj(WordSearchModel.self)
//            .subscribe(onNext: { (response) in
//                SVProgressHUD.dismiss()
//
//                let popUpView = SearchPopUpView()
//                popUpView.setInfo(word: response.word!)
//                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//                alertView.setValue(popUpView, forKey: "contentViewController")
//
//                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alertView, animated: true, completion: nil)
//
//            }, onError: { (error) in
//                SVProgressHUD.showError(withStatus: error.rawString())
//            })
//    }
//}

