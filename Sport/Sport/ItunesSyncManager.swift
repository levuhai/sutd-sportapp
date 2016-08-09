//
//  ItunesDataImporter.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer
import AVFoundation

protocol ItunesDataImporterDelegate {
    
}

class ItunesSyncManager: NSObject, SongSyncManager {
    
    static let sharedInstance = ItunesSyncManager()
    
    let opQueue = NSOperationQueue()
    
    override init() {
        super.init()
        
        opQueue.maxConcurrentOperationCount = 1
    }
    
    func syncWithRepo(repository: SongRepository, progress: ((current: Int, total: Int) -> ())?, completion: (() -> Void)?) {
        func isExistInItuneLibrary(songPersistentId: String) -> Bool {
                let query = MPMediaQuery.songsQuery()
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
    
    func importToRepository(repository: SongRepository, progress: ((current: Int, total: Int) -> ())?,  completion: (()->())?) {
        let mediaQuery = MPMediaQuery.songsQuery()
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
                dispatch_async(dispatch_get_main_queue(), { 
                    progress?(current: count, total: total)
                })
            }
            
            opQueue.addOperation(op)
        }
        print(opQueue.operationCount)
        if (completion != nil) {
            opQueue.addOperationWithBlock({ 
                dispatch_async(dispatch_get_main_queue(), completion!)
            })
        }
    }
}
