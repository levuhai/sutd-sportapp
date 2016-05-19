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
    
    private let realmConfig: Realm.Configuration!

    private lazy var realm: Realm = {
        print("Execute once")
        return try! Realm(configuration: self.realmConfig)
    }()
    
    private let realmDispatchQueue = dispatch_queue_create("com.tiennth.Sport.realm_queue", DISPATCH_QUEUE_SERIAL)
    
    override init() {
        
        // Create custom Realm configuration.
        // Config Realm with new file name.
        realmConfig = Realm.Configuration.defaultConfiguration
        realmConfig.fileURL = realmConfig.fileURL?.URLByDeletingLastPathComponent?.URLByAppendingPathComponent(Constants.Realm.fileName)
        
        super.init()
        print(realm.configuration.fileURL!)
    }
    
    func execute(block: (realm: Realm)->()) {
        // Use dispatch_sync here to ensure we dont break flow of calling function.
        dispatch_sync(realmDispatchQueue) { 
            block(realm: self.realm)
        }
    }
}
