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
}