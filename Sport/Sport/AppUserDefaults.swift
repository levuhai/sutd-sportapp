//
//  AppUserDefaults.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class AppUserDefaults: NSObject {
    static var energy: Float = 0.0
    static var valence: Float = 0.0
    static var tempo: Float = 0.0
    
    fileprivate static let SP_LAST_TEMPO_KEY = "last_tempo"
    fileprivate static let SP_LAST_ENERGY_KEY = "last_energy"
    fileprivate static let SP_LAST_VALENCE_KEY = "last_valence"
    fileprivate static let SP_INITIALIZED = "initialized"
    fileprivate static let SP_TUTORIAL_FINISHED = "tutorial_finished"
    
    class func saveLastTempo(_ tempo: Float) {
        self.tempo = tempo
        UserDefaults.standard.set(tempo, forKey: SP_LAST_TEMPO_KEY)
    }
    
    class func saveLastEnergy(_ energy: Float) {
        self.energy = energy
        UserDefaults.standard.set(energy, forKey: SP_LAST_ENERGY_KEY)
    }
    
    class func saveLastValence(_ valence: Float) {
        self.valence = valence
        UserDefaults.standard.set(valence, forKey: SP_LAST_VALENCE_KEY)
    }
    
    class func lastTempo() -> Float? {
        tempo = (UserDefaults.standard.object(forKey: SP_LAST_TEMPO_KEY) as AnyObject).floatValue ?? 0.0
        return tempo
    }
    
    class func lastEnergy() -> Float? {
        energy = (UserDefaults.standard.object(forKey: SP_LAST_ENERGY_KEY) as AnyObject).floatValue ?? 0.0
        return energy
    }
    
    class func lastValence() -> Float? {
        valence = (UserDefaults.standard.object(forKey: SP_LAST_VALENCE_KEY) as AnyObject).floatValue ?? 0
        return valence
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
