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
    
    var stepCounterTimer: NSTimer?
    var stepCounterInterval: NSTimeInterval = 0
    var lastQueriedDate: NSDate!
    var handler: ((totalStep: Int) -> Void)?
    
    var stepCounts = 0
    
    func reset() {
        stepCounts = 0
    }
    
    func startPedometerWithUpdateInterval(interval: NSTimeInterval, handler: (totalSteps: Int) -> Void) {
        self.handler = handler
        self.stepCounterInterval = interval
        startStepCounter()
    }
    
    func startStepCounter() {
        if CMPedometer.isStepCountingAvailable() {
            // Using system step counter.
            stepCounterTimer?.invalidate()
            lastQueriedDate = NSDate()
            stepCounterTimer = NSTimer.scheduledTimerWithTimeInterval(stepCounterInterval, target: self, selector: #selector(queryStepCount), userInfo: nil, repeats: true)
        } else {
            // Start my own step counter.
            // TODO:
        }
    }
    
    func queryStepCount() {
        let newDate = NSDate()
        pedometer.queryPedometerDataFromDate(lastQueriedDate, toDate: newDate, withHandler: { [unowned self] (data, error) in
            guard let data = data else {
                return
            }
            let stepCount = data.numberOfSteps.integerValue
            self.stepCounts += stepCount
            
            dispatch_async(dispatch_get_main_queue(), {
                self.handler?(totalStep: self.stepCounts)
            })
            })
        lastQueriedDate = newDate
    }
    
    func stopStepCounter() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.stopPedometerUpdates()
        } else {
            // Stop my own step counter.
            // TODO:
        }
    }

}
