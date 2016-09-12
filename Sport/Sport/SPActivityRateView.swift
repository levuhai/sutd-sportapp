//
//  SPActivityRateView.swift
//  Sport
//
//  Created by Tien on 6/17/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol SPActivityRateViewDataSource: NSObjectProtocol {
    func dataForActivityRateView(view: SPActivityRateView) -> Float
}

class SPActivityRateView: UIView {
    
    let maximumValue = Float(1.2)
    let minimumValue = Float(0)
    let horizontalSpacing: CGFloat = 1
    let top: CGFloat = 10
    let bottom: CGFloat = 10
    let left: CGFloat = 10
    
    var activityRates = [Float]()

    var path = UIBezierPath()
    
    var lastRefresh = NSDate()
    let drawInterval: NSTimeInterval = 1.0 / 60
    
    var expiredIndex: Int = 0
    
    var drawingTimer: NSTimer?
    
    weak var dataSource: SPActivityRateViewDataSource?
    
    // MARK: - Functions
    // ===============================================================================
    // FUNCTIONS
    
    func startReceivingUpdate() {
        guard let _ = dataSource else {
            return
        }
        drawingTimer = NSTimer.scheduledTimerWithTimeInterval(drawInterval, target: self, selector: #selector(timerDidTick(_:)), userInfo: nil, repeats: true)
    }
    
    func stopReceivingUpdates() {
        drawingTimer?.invalidate()
    }
    
    func timerDidTick(timer: NSTimer) {
        let value = dataSource!.dataForActivityRateView(self)
        add(value)
        
        reloadData()
    }
    
    func add(value: Float) {
        if (expiredIndex > 0) {
            activityRates.removeLast(activityRates.count - expiredIndex)
        }
        activityRates.insert(value, atIndex: 0)
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
        
        for index in 1..<data.count {
            let value = data[index]
            let y = CGFloat(1 - value / valueLength) * height
            path.addLineToPoint(CGPoint(x: x, y: y))
            x -= horizontalSpacing
            
            if x < 0 {
                expiredIndex = index + 1
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
