//
//  SPActivityRateView.swift
//  Sport
//
//  Created by Tien on 6/17/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SPActivityRateView: UIView {
    
    var maximumValue = Float(2)
    let minimumValue = Float(0)
    
    var activityRates = [Float]()
    
    let horizontalSpacing: CGFloat = 1
    let top: CGFloat = 10
    let bottom: CGFloat = 10
    let left: CGFloat = 10
    
    var path = UIBezierPath()
    
    var lastRefresh = NSDate()
    let drawInterval: NSTimeInterval = 0.2
    
    func add(value: Float) {
        activityRates.append(value)
        
        reloadData()
    }
    
    override func layoutSubviews() {
        reloadData()
    }
    
    func reloadData() {
        path = pathFromData(activityRates, bounds: bounds, maxValue: maximumValue, minValue: minimumValue)
        let currentDate = NSDate()
        if currentDate.timeIntervalSinceDate(lastRefresh) > drawInterval {
            setNeedsDisplay()
        }
    }
    
    func pathFromData(data: [Float], bounds: CGRect, maxValue: Float, minValue: Float) -> UIBezierPath {
        let path = UIBezierPath()
        var x = bounds.size.width
        let height = bounds.size.height - top - bottom
        let valueLength = maxValue - minValue
        
        if data.count == 0 {
            return path
        }
        
        let lastY = CGFloat(1 - data[0] / valueLength) * height
        path.moveToPoint(CGPoint(x: x, y: lastY))
        
        for index in (1..<data.count).reverse() {
            let value = data[index]
            let y = CGFloat(1 - value / valueLength) * height
            path.addLineToPoint(CGPoint(x: x, y: y))
            x -= horizontalSpacing
            
            if x < 0 {
                break
            }
        }
        
        return path
    }
    
    override func drawRect(rect: CGRect) {
        lastRefresh = NSDate()
        UIColor.whiteColor().setStroke()
        path.stroke()
    }

}
