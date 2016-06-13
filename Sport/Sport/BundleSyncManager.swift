//
//  BundleDataImporter.swift
//  Sport
//
//  Created by Tien on 5/18/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer

class BundleDataImporter: SongSyncManager {
    
    static let sharedInstance = BundleDataImporter()
    
    func importToRepository(repository: SongRepository, completion: (() -> ())?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            let songPaths = NSBundle.mainBundle().pathsForResourcesOfType(nil, inDirectory: "songs")
            print("Count: \(songPaths.count)")
            var count = 0
            for path in songPaths {
                
                let analysisOutput = AubioWrapper.simpleAnalyzeAudioFile(path)
                let persistentId = "persistent_id\(count)"
                count += 1
                let songData = SongData(persistentId: persistentId, energy: analysisOutput.energy, valence: analysisOutput.valence, tempo: analysisOutput.tempo)
                
                repository.addSong(songData)
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                completion?()
            })
        }
    }
    
    func syncWithRepo(repository: SongRepository, completion: (() -> ())?) {
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
        
        importToRepository(repository, completion: completion)
    }
}
