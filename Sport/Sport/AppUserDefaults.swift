//
//  AppUserDefaults.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class AppUserDefaults: NSObject {
    fileprivate static let SP_LAST_TEMPO_KEY = "last_tempo"
    fileprivate static let SP_INITIALIZED = "initialized"
    fileprivate static let SP_TUTORIAL_FINISHED = "tutorial_finished"
    
    class func saveLastTempo(_ tempo: Float) {
        UserDefaults.standard.set(tempo, forKey: SP_LAST_TEMPO_KEY)
    }
    
    class func lastTempo() -> Float? {
        return (UserDefaults.standard.object(forKey: SP_LAST_TEMPO_KEY) as AnyObject).floatValue
    }
    
    class func saveInitializeStatus(_ finished: Bool) {
        UserDefaults.standard.set(finished, forKey: SP_INITIALIZED)
        UserDefaults.standard.synchronize()
    }
    
    class func isFirstInitialSuccessfully() -> Bool {
        return (UserDefaults.standard.object(forKey: SP_INITIALIZED) as AnyObject).boolValue ?? false
    }
    
    class func saveTutorialStatus(_ finished: Bool) {
        UserDefaults.standard.set(finished, forKey: SP_TUTORIAL_FINISHED)
        UserDefaults.standard.synchronize()
    }
    
    class func isTutorialFinished() -> Bool {
        return (UserDefaults.standard.object(forKey: SP_TUTORIAL_FINISHED) as AnyObject).boolValue ?? false
    }
}
