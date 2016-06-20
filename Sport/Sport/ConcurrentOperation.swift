//
//  ConcurrentOperation.swift
//  Sport
//
//  Created by Tien on 6/21/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class ConcurrentOperation: NSOperation {
    override var asynchronous: Bool {
        get {
            return true
        }
    }
    
    var _finished = false
    override var finished: Bool {
        set {
            if newValue != _finished {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
        
        get {
            return _finished
        }
    }
    
    var _ready = false
    override var ready: Bool {
        set {
            if newValue != _ready {
                willChangeValueForKey("isReady")
                _ready = newValue
                didChangeValueForKey("isReady")
            }
        }
        
        get {
            return _ready
        }
    }
    
    var _executing = false
    override var executing: Bool {
        set {
            if newValue != _executing {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
        
        get {
            return _executing
        }
    }
    
    override init() {
        super.init()
        
        _finished = super.finished
        _executing = super.executing
        _ready = super.ready
    }
    
    override func start() {
        if cancelled {
            executing = false
            finished = true
            return
        }
        
        finished = false
        executing = true
    }
}
