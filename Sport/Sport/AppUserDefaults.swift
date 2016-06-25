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
    
    class func saveLastTempo(tempo: Float) {
        NSUserDefaults.standardUserDefaults().setObject(tempo, forKey: SP_LAST_TEMPO_KEY)
    }
    
    class func lastTempo() -> Float? {
        return NSUserDefaults.standardUserDefaults().objectForKey(SP_LAST_TEMPO_KEY)?.floatValue
    }
    
    class func isFirstInitialSuccessfully() -> Bool {
        return false
    }
}
