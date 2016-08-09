//
//  SPSlider.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SPSlider: UISlider {

    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        let trackHeight: CGFloat = 6
        return CGRectMake(0, (bounds.height - trackHeight) / 2, bounds.width, trackHeight)
    }
}
