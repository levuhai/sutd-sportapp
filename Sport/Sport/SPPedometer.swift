//
//  SPPedometer.swift
//  Sport
//
//  Created by Tien on 7/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import CoreMotion

class SPPedometer: NSObject {
    let pedometer = CMPedometer()
    
    var stepCounterTimer: Timer?
    var stepCounterInterval: TimeInterval = 0
    var lastQueriedDate: Date!
    var handler: ((_ totalStep: Int) -> Void)?
    
    var stepCounts = 0
    
    func reset() {
        stepCounts = 0
    }
    
    func startPedometerWithUpdateInterval(_ interval: TimeInterval, handler: @escaping (_ totalSteps: Int) -> Void) {
        self.handler = handler
        self.stepCounterInterval = interval
        startStepCounter()
    }
    
    func startStepCounter() {
        if CMPedometer.isStepCountingAvailable() {
            // Using system step counter.
            stepCounterTimer?.invalidate()
            lastQueriedDate = Date()
            stepCounterTimer = Timer.scheduledTimer(timeInterval: stepCounterInterval, target: self, selector: #selector(queryStepCount), userInfo: nil, repeats: true)
        } else {
            // Start my own step counter.
            // TODO:
        }
    }
    
    func queryStepCount() {
        let newDate = Date()
        pedometer.queryPedometerData(from: lastQueriedDate, to: newDate, withHandler: { [unowned self] (data, error) in
            guard let data = data else {
                return
            }
            let stepCount = data.numberOfSteps.intValue
            self.stepCounts += stepCount
            
            DispatchQueue.main.async(execute: {
                self.handler?(self.stepCounts)
            })
            })
        lastQueriedDate = newDate
    }
    
    func stopStepCounter() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.stopUpdates()
        } else {
            // Stop my own step counter.
            // TODO:
        }
    }

}
