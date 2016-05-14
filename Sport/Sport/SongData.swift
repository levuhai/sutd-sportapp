
//
//  Song.swift
//  Sport
//
//  Created by Tien on 5/14/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import RealmSwift

class SongData: Object {
    dynamic var songName = ""
    dynamic var energy = 0.0
    dynamic var valence = 0.0
    dynamic var tempo = 0.0
    
    dynamic var rms = 0.0
}
