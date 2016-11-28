//
//  SPSlider.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SPSlider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let trackHeight: CGFloat = 6
        return CGRect(x: 0, y: (bounds.height - trackHeight) / 2, width: bounds.width, height: trackHeight)
    }
}
