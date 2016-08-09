//
//  AppUserDefaults.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class AppUserDefaults: NSObject {
    private static let SP_LAST_TEMPO_KEY = "last_tempo"
    private static let SP_INITIALIZED = "initialized"
    private static let SP_TUTORIAL_FINISHED = "tutorial_finished"
    
    class func saveLastTempo(tempo: Float) {
        NSUserDefaults.standardUserDefaults().setObject(tempo, forKey: SP_LAST_TEMPO_KEY)
    }
    
    class func lastTempo() -> Float? {
        return NSUserDefaults.standardUserDefaults().objectForKey(SP_LAST_TEMPO_KEY)?.floatValue
    }
    
    class func saveInitializeStatus(finished: Bool) {
        NSUserDefaults.standardUserDefaults().setObject(finished, forKey: SP_INITIALIZED)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func isFirstInitialSuccessfully() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(SP_INITIALIZED)?.boolValue ?? false
    }
    
    class func saveTutorialStatus(finished: Bool) {
        NSUserDefaults.standardUserDefaults().setObject(finished, forKey: SP_TUTORIAL_FINISHED)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func isTutorialFinished() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(SP_TUTORIAL_FINISHED)?.boolValue ?? false
    }
}
