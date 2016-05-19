//
//  SongRepositories.swift
//  Sport
//
//  Created by Tien on 5/18/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SongRepositories: NSObject {

    static let realmRepository = SongRealmRepository(songImporter: BundleDataImporter.sharedInstance)

}
