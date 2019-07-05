//
// Created by ac on 2019-07-04.
// Copyright (c) 2019 Fin. All rights reserved.
//

import UIKit
import Foundation

extension UILabel{
    func actualHeight(_ labelWidth:CGFloat,_ labelText:String) -> CGFloat {

        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = self.numberOfLines
        label.lineBreakMode = self.lineBreakMode
        label.font = self.font
        label.text = labelText
        label.sizeToFit()

        return label.frame.height
    }
}