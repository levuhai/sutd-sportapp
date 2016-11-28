//
//  ConcurrentOperation.swift
//  Sport
//
//  Created by Tien on 6/21/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class ConcurrentOperation: Operation {
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    var _finished = false
    override var isFinished: Bool {
        set {
            if newValue != _finished {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
        
        get {
            return _finished
        }
    }
    
    var _ready = false
    override var isReady: Bool {
        set {
            if newValue != _ready {
                willChangeValue(forKey: "isReady")
                _ready = newValue
                didChangeValue(forKey: "isReady")
            }
        }
        
        get {
            return _ready
        }
    }
    
    var _executing = false
    override var isExecuting: Bool {
        set {
            if newValue != _executing {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
        
        get {
            return _executing
        }
    }
    
    override init() {
        super.init()
        
        _finished = super.isFinished
        _executing = super.isExecuting
        _ready = super.isReady
    }
    
    override func start() {
        if isCancelled {
            isExecuting = false
            isFinished = true
            return
        }
        
        isFinished = false
        isExecuting = true
    }
}
