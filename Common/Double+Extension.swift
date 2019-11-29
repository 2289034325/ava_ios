//
//  Double+Extension.swift
//  AVA-Swift
//
//  Created by ac on 11/29/19.
//  Copyright © 2019 Fin. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
