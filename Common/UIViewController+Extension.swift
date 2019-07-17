//
// Created by ac on 2019-07-05.
// Copyright (c) 2019 Fin. All rights reserved.
//

import Foundation
import UIKit

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
}
