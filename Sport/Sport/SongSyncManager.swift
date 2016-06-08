//
//  SongSyncManager.swift
//  Sport
//
//  Created by Tien on 5/17/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol SongSyncManager: class {
    func syncWithRepo(repository: SongRepository, completion: (()->())?)
}
