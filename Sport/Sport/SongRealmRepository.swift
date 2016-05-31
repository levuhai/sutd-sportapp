//
//  SongRealmRepository.swift
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SongRealmRepository: SongRepository {
    
    func addSong(song: SongData) {
        print("Song added \(song.persistentId), \(song.title)")
        
        let realm = RealmFactory.sharedInstance.newRealm()
        realm.beginWrite()
        realm.add(song)
        try! realm.commitWrite()
    }
    
    func addSongs(songs: [SongData]) {
        
    }
    
    func isSongExisting(persistenceId: String) -> Bool {
        var isExisting = false
        let realm = RealmFactory.sharedInstance.newRealm()
        let predicate = NSPredicate(format: "\(SongData.Column.PersistentId) == %@", persistenceId)
        let songs = realm.objects(SongData).filter(predicate)
        isExisting = songs.count > 0
        return isExisting
    }
    
    func loadSongs() -> [SongData] {
        let realm = RealmFactory.sharedInstance.newRealm()
        let result = realm.objects(SongData)
        return Array(result)
    }
    
    func loadSongs(tempo: Float) -> [SongData] {
        let realm = RealmFactory.sharedInstance.newRealm()
        let predicate = NSPredicate(format: "\(SongData.Column.Tempo) BETWEEN {%f, %f}", tempo - 10, tempo + 10)
        let result = realm.objects(SongData).filter(predicate)
        return Array(result)
    }
}
