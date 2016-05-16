
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
    // Persistent ID of this song in itunes library.
    dynamic var persistentId = ""
    
    // Song title.
    dynamic var title = ""
    
    // Analyzed data.
    dynamic var energy = 0.0
    dynamic var valence = 0.0
    dynamic var tempo = 0.0
    dynamic var rms = 0.0
    
    init(persistentId: String, title: String, energy: Double, valence: Double, tempo: Double) {
        self.persistentId = persistentId
        self.title = title
        
        self.energy = energy
        self.valence = valence
        self.tempo = tempo
    }
}
