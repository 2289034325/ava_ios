//
// Created by ac on 2019-07-04.
// Copyright (c) 2019 Fin. All rights reserved.
//

import UIKit
import Foundation

extension UILabel{
    func actualHeight(_ labelWidth:CGFloat) -> CGFloat {

        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = self.numberOfLines
        label.lineBreakMode = self.lineBreakMode
        label.font = self.font
        if(self.text?.isEmpty ?? true){
            // 空白的label应当也能占据一定高度
            label.text = " "
        }
        else{
            label.text = self.text
        }
        label.sizeToFit()

        return label.frame.height
    }
}
