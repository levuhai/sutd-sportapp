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
    let activityManager = CMMotionActivityManager()
    
    var stepCounterTimer: Timer?
    var stepCounterInterval: TimeInterval = 0
    var activityStr = ""
    var lastQueriedDate: Date!
    var handler: ((_ totalStep: Int, _ stepsPerSecond: NSNumber) -> Void)?
    var activityHandler: ((_ activity: String) -> Void)?
    
    var stepCounts = 0
    var stepsPerSecond: NSNumber?
    func reset() {
        stepCounts = 0
    }
    
    func startPedometerWithUpdateInterval(_ interval: TimeInterval, handler: @escaping (_ totalSteps: Int, _ stepsPerSecond: NSNumber) -> Void) {
        self.handler = handler
        self.stepCounterInterval = interval
        
        startStepCounter()
    }
    
    func startActivityUpdate(_ handler: @escaping (_ activity: String) -> Void) {
        self.activityHandler = handler
        
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (data) -> Void in
                
                if(data?.stationary == true) {
                    self.activityStr = "Standing"
                } else if (data?.walking == true){
                    self.activityStr = "Walking"
                } else if (data?.running == true){
                    self.activityStr = "Running"
                } else if (data?.automotive == true){
                    self.activityStr = "Standing"
                }
                
                DispatchQueue.main.async(execute: {
                    self.activityHandler?(self.activityStr)
                })
            })
        }
    }
    
    func startStepCounter() {
        
        if CMPedometer.isStepCountingAvailable() {
            // Start update pedometer
            pedometer.startUpdates(from: Date(), withHandler: { (data, error) in
                if let data = data {
                    self.stepCounts = data.numberOfSteps.intValue
                    self.stepsPerSecond = data.currentCadence
                    
                    //let distance = data.distance
                    DispatchQueue.main.async(execute: {
                        self.handler?(self.stepCounts, self.stepsPerSecond ?? 0)
                    })
                }
            })
        }
//        else {
//            // Start my own step counter.
//            // TODO:
////            // Using system step counter.
////            stepCounterTimer?.invalidate()
////            lastQueriedDate = Date()
////            stepCounterTimer = Timer.scheduledTimer(timeInterval: stepCounterInterval, target: self, selector: #selector(queryStepCount), userInfo: nil, repeats: true)
//        }
    }
    
    func stopStepCounter() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.stopUpdates()
            activityManager.stopActivityUpdates()
        } else {
            // Stop my own step counter.
            // TODO:
        }
    }

}
