//
//  RealmFactory.swift
//  Sport
//
//  Created by Tien on 5/15/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RealmFactory: NSObject {
    static let sharedInstance = RealmFactory()
    
    fileprivate let realmConfig: Realm.Configuration!

    override init() {
        
        // Create custom Realm configuration.
        // Config Realm with new file name.
        realmConfig = Realm.Configuration.defaultConfiguration
        realmConfig.fileURL = realmConfig.fileURL?.deletingLastPathComponent().URLByAppendingPathComponent(Constants.Realm.fileName)
        
        super.init()
    }
    
    func newRealm() -> Realm {
        return try! Realm(configuration: realmConfig)
    }
}
