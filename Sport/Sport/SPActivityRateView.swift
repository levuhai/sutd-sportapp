//
//  SPActivityRateView.swift
//  Sport
//
//  Created by Tien on 6/17/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol SPActivityRateViewDataSource: NSObjectProtocol {
    func dataForActivityRateView(_ view: SPActivityRateView) -> Float
}

class SPActivityRateView: UIView {
    
    let maximumValue = Float(220)
    let minimumValue = Float(80)
    let horizontalSpacing: CGFloat = 1
    let top: CGFloat = 15
    let bottom: CGFloat = 20
    let left: CGFloat = 10
    
    var activityRates = [Float]()

    var path = UIBezierPath()
    
    var lastRefresh = Date()
    let drawInterval: TimeInterval = 1.0 / 50
    
    var expiredIndex: Int = 0
    
    var drawingTimer: Timer?
    
    weak var dataSource: SPActivityRateViewDataSource?
    
    // MARK: - Functions
    // ===============================================================================
    // FUNCTIONS
    
    func startReceivingUpdate() {
        guard let _ = dataSource else {
            return
        }
        drawingTimer = Timer.scheduledTimer(timeInterval: drawInterval, target: self, selector: #selector(timerDidTick(_:)), userInfo: nil, repeats: true)
    }
    
    func stopReceivingUpdates() {
        drawingTimer?.invalidate()
    }
    
    func timerDidTick(_ timer: Timer) {
        let value = dataSource!.dataForActivityRateView(self)
        add(value)
        
        reloadData()
    }
    
    func add(_ value: Float) {
        if (expiredIndex > 0) {
            activityRates.removeLast(activityRates.count - expiredIndex)
        }
        activityRates.insert(value, at: 0)
    }
    
    override func layoutSubviews() {
        reloadData()
    }
    
    func reloadData() {
        path = pathFromData(activityRates, bounds: bounds, maxValue: maximumValue, minValue: minimumValue)
        let currentDate = Date()
        if currentDate.timeIntervalSince(lastRefresh) > drawInterval {
            setNeedsDisplay()
        }
    }
    
    func pathFromData(_ data: [Float], bounds: CGRect, maxValue: Float, minValue: Float) -> UIBezierPath {
        let path = UIBezierPath()
        
        var x = bounds.size.width
        let height = bounds.size.height - top - bottom
        let valueLength = maxValue
        
        if data.count == 0 {
            return path
        }
        
        let lastY = height-CGFloat(data[0] / valueLength) * height
        path.move(to: CGPoint(x: x, y: lastY))
        
        for index in 1..<data.count {
            let value = data[index]
            let y = height - CGFloat(value / valueLength) * height
            path.addLine(to: CGPoint(x: x, y: y))
            x -= horizontalSpacing
            
            if x < 0 {
                expiredIndex = index + 1
                break
            }
        }
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        lastRefresh = Date()
        UIColor.init(red: 246/255.0, green: 56/255.0, blue: 85/255.0, alpha: 1).setStroke()
        path.stroke()
    }

}
