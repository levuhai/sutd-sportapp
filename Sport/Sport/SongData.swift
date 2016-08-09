
//
//  Song.swift
//  Sport
//
//  Created by Tien on 5/14/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SongData: Object {
    
    // Name of column should exactly match property name.
    struct Column {
        static let PersistentId = "persistentId"
        static let Tempo = "tempo"
    }
    
    // Persistent ID of this song in itunes library.
    dynamic var persistentId = ""
    
    // Analyzed data.
    dynamic var energy = 0.0
    dynamic var valence = 0.0
    dynamic var tempo = 0.0
    dynamic var rms = 0.0
    
    init(persistentId: String, energy: Double, valence: Double, tempo: Double) {
        self.persistentId = persistentId
        
        self.energy = energy
        self.valence = valence
        self.tempo = tempo
        
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    override static func primaryKey() -> String? {
        return Column.PersistentId
    }
}
