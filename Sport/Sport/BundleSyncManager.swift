//
//  BundleSyncManager.swift
//  Sport
//
//  Created by Tien on 5/18/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer
import AudioKit

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


class BundleSyncManager: SongSyncManager {
    
    static let sharedInstance = BundleSyncManager()
    
    func importToRepository(_ repository: SongRepository, completion: (() -> ())?) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { 
            let songPaths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "songs")
            print("Count: \(songPaths.count)")
            var count = 0
            for path in songPaths {
                
//                let file = try! AKAudioFile(forReading: URL(fileURLWithPath: path))
//                print(file.samplesCount)
                
                let analysisOutput = AubioWrapper.analyzeAudioFile(path)
                let persistentId = "persistent_id\(count)"
                count += 1
                let songData = SongData(persistentId: persistentId, energy: (analysisOutput?.energy)!, valence: (analysisOutput?.valence)!, tempo: (analysisOutput?.tempo)!)
                
                repository.addSong(songData)
            }
            
            DispatchQueue.main.async(execute: { 
                completion?()
            })
        }
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
        
        importToRepository(repository, completion: completion)
    }
}
