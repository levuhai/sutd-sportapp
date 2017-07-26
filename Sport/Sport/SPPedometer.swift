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
    var usingStepCounting = false
    let pedometer = CMPedometer()
    let activityManager = CMMotionActivityManager()
    var accelSamplesPerSecond = 60.0
    var stepCounterTimer: Timer?
    var stepCounterInterval: TimeInterval = 0
    var activityStr = ""
    var lastQueriedDate: Date!
    var handler: ((_ totalStep: Int, _ stepsPerSecond: Float) -> Void)?
    var activityHandler: ((_ activity: String) -> Void)?
    
    var stepCounts = 0
    var isSleeping = false
    var stepsPerSecond: Float = 0.0
    
    // Accelerometer
    let motionManager = CMMotionManager()
    
    let rightLegThreshold = 0.93
    let leftLegThreshold = 0.96
    
    var lastAccelerometerData: CMAccelerometerData? = nil
    var lastAccelerometerDataStepTracking: CMAccelerometerData? = nil
    var dvalArray = [Double]()
    var stepArray = [Int]()
    var stepTimer: Timer?
    
    func reset() {
        stepCounts = 0
    }
    
    func startPedometerWithUpdateInterval(_ interval: TimeInterval, handler: @escaping (_ totalSteps: Int, _ stepsPerSecond: Float) -> Void) {
        self.handler = handler
        stepCounterInterval = interval
        usingStepCounting = CMPedometer.isStepCountingAvailable()
        
        if usingStepCounting {
            // Start update pedometer
            pedometer.startUpdates(from: Date(), withHandler: { (data, error) in
                if data != nil {
                    //let distance = data.distance
                    DispatchQueue.main.async(execute: {
                        self.stepCounts = data!.numberOfSteps.intValue
                        print("Step count: \(self.stepCounts)")
                        self.stepsPerSecond = data!.currentCadence?.floatValue ?? 0.0
                        self.handler?(self.stepCounts, self.stepsPerSecond)
                    })
                }
            })
        } else {
            if !motionManager.isAccelerometerAvailable {
                return
            }
            initStepArr()
            motionManager.accelerometerUpdateInterval = 1.0/accelSamplesPerSecond
            motionManager.startAccelerometerUpdates()
            
            
            stepTimer?.invalidate()
            stepTimer = Timer.scheduledTimer(timeInterval: stepCounterInterval, target: self, selector: #selector(updateTotalStep), userInfo: nil, repeats: true)
        }
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
    
    func stopStepCounter() {
        if usingStepCounting {
            pedometer.stopUpdates()
            activityManager.stopActivityUpdates()
            stepCounts = 0
        } else {
            stepTimer?.invalidate()
            motionManager.stopAccelerometerUpdates()
            stepCounts = 0
        }
    }
    
    // Accelerometer
    func updateTotalStep() {
        let nilableAccelerometerData = motionManager.accelerometerData

        guard let accelerometerData = nilableAccelerometerData, let lastAccelerometerData = self.lastAccelerometerDataStepTracking else {
            self.lastAccelerometerDataStepTracking = nilableAccelerometerData
            return
        }

        let dValue = calculateDValue(accelerometerData, lastAccel: lastAccelerometerData)
        self.lastAccelerometerDataStepTracking = accelerometerData
        storeDvalue(dValue, dvaltable: &self.dvalArray)
        
        let wma = self.calculateWMA(self.dvalArray)
        //print("\(stepCounts) \(wma)")
        if (wma < rightLegThreshold && dvalArray.count > 10 && !isSleeping) {
            isSleeping = true;
            stepCounts += 1
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(wakeUp), userInfo: nil, repeats: false)
        }
        storeStep(stepCounts)
        calculateStepsPerSecond()
        
        DispatchQueue.main.async(execute: {
            self.handler?(self.stepCounts, self.stepsPerSecond)
        })
    }
    
    func wakeUp() {
        isSleeping = false
    }
    
    func calculateDValue(_ currentAccel: CMAccelerometerData, lastAccel: CMAccelerometerData) -> Double {
        
        let x = currentAccel.acceleration.x
        let y = currentAccel.acceleration.y
        let z = currentAccel.acceleration.z
        
        let x0 = lastAccel.acceleration.x
        let y0 = lastAccel.acceleration.y
        let z0 = lastAccel.acceleration.z
        
        let d = (x*x0 + y*y0 + z*z0) / sqrt((x*x + y*y + z*z) * (x0*x0 + y0*y0 + z0*z0));
        return d
    }
    
    func calculateWMA(_ dvaltable: [Double]) -> Double {
        var sum: Double = 0
        var factor: Double = 10
        if dvaltable.count >= 10 {
            for index in (0..<10).reversed() {
                sum += factor * dvaltable[index]
                factor -= 1
            }
        }
        return sum / 55
    }
    
    func storeDvalue(_ value: Double, dvaltable: inout [Double]) {
        if (dvaltable.count > 60) {
            dvaltable.removeFirst()
        }
        dvaltable.append(value)
    }

    func initStepArr() {
        for _ in (0..<Int(accelSamplesPerSecond)*5) {
            stepArray.append(0)
        }
    }
    
    func storeStep(_ value: Int) {
        if (stepArray.count > Int(accelSamplesPerSecond)*5) {
            stepArray.removeFirst()
        }
        stepArray.append(value)
    }
    
    func calculateStepsPerSecond() {
        self.stepsPerSecond  = Float(stepArray.last! - stepArray.first!)/5.0
        if(self.stepsPerSecond > 3.166) {
            self.stepsPerSecond = 190.0/60.0
        }
    }

}
