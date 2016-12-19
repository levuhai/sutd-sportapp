//
//  Constants.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class Constants: NSObject {
    struct Realm {
        static let fileName = "Sport.realm"
    }
    
    struct Defaults {
        static let tempoMin: Float = 20.0
        static let tempoMax: Float = 250.0
        
        static let energyMin: Float = -30
        static let energyMax: Float = -10
        
        static let valenceMin: Float = -1.0
        static let valenceMax: Float = 1.0
    }
}
