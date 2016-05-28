//
//  UINavigationBar+Sport.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor) {
        let navigationSeparator = UIView(frame: CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5))
        navigationSeparator.backgroundColor = color
        navigationSeparator.opaque = true
        self.addSubview(navigationSeparator)
    }
}