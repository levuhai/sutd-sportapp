//
//  RealmManager.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RealmManager: NSObject {
    static let sharedInstance = RealmManager()
    
    let realm: Realm!
    
    override init() {
        
        // Create custom Realm configuration.
        // Config Realm with new file name.
        var realmConfig = Realm.Configuration.defaultConfiguration
        realmConfig.fileURL = realmConfig.fileURL?.URLByDeletingLastPathComponent?.URLByAppendingPathComponent(Constants.Realm.fileName)
        
        realm = try! Realm(configuration: realmConfig)
        super.init()
        print(realm.configuration.fileURL!)
    }
    
}
