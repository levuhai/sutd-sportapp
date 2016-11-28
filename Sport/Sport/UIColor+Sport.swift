//
//  UIColor+Sport.swift
//  Sport
//
//  Created by Tien on 5/26/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

extension UIColor {
    class func sportPink() -> UIColor {
        return UIColorFromRGB(0xF63855)
    }
    
    class func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
