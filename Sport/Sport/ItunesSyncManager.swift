//
//  ItunesDataImporter.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer
import AVFoundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol ItunesDataImporterDelegate {
    
}

class ItunesSyncManager: NSObject, SongSyncManager {
    
    static let sharedInstance = ItunesSyncManager()
    
    let opQueue = OperationQueue()
    
    override init() {
        super.init()
        
        opQueue.maxConcurrentOperationCount = 1
    }
    
    func syncWithRepo(_ repository: SongRepository, progress: ((_ current: Int, _ total: Int) -> ())?, completion: (() -> Void)?) {
        
        func isExistInItuneLibrary(_ songPersistentId: String) -> Bool {
                let query = MPMediaQuery.songs()
                let predicate = MPMediaPropertyPredicate(value: songPersistentId, forProperty: MPMediaItemPropertyPersistentID)
                query.addFilterPredicate(predicate)
                return query.items?.count > 0
        }
        
        // Remove all songs that doesn't exist in Ipod library any more.
        let localSongList = repository.loadSongs()
        for localSong in localSongList {
            let isExisting = isExistInItuneLibrary(localSong.persistentId)
            if !isExisting {
                repository.deleteSong(localSong.persistentId)
            }
        }
        
        importToRepository(repository, progress: progress, completion: completion)
    }
    
    func importToRepository(_ repository: SongRepository, progress: ((_ current: Int, _ total: Int) -> ())?,  completion: (()->())?) {
        let mediaQuery = MPMediaQuery.songs()
        let mediaItems = mediaQuery.items;
        
        guard let songs  = mediaItems else {
            completion?()
            return
        }
        
        let total = songs.count
        var count = 0
        for song in songs {
            let op = SingleAnalysisOperation(song: song, repository: repository)
            op.completionBlock = {
                count += 1
                DispatchQueue.main.async(execute: { 
                    progress?(count, total)
                })
            }
            
            opQueue.addOperation(op)
        }
        print(opQueue.operationCount)
        if (completion != nil) {
            opQueue.addOperation({ 
                DispatchQueue.main.async(execute: completion!)
            })
        }
    }
}
