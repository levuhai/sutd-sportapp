//
//  SongRealmRepository.swift
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer

class SongRealmRepository: SongRepository {
    
    static let sharedInstance = SongRealmRepository()
    
    func addSong(_ song: SongData) {
        let realm = RealmFactory.sharedInstance.newRealm()
        realm.beginWrite()
        realm.add(song)
        try! realm.commitWrite()
    }
    
    func addSongs(_ songs: [SongData]) {
        
    }
    
    func isSongExisting(_ persistenceId: String) -> Bool {
        let realm = RealmFactory.sharedInstance.newRealm()
        return realm.object(ofType: SongData.self, forPrimaryKey: persistenceId as AnyObject) != nil
    }
    
    func loadSongs() -> [SongData] {
        let realm = RealmFactory.sharedInstance.newRealm()
        let result = realm.objects(SongData)
        return Array(result)
    }
    
    func loadSongs(_ tempo: Float) -> [SongData] {
        let realm = RealmFactory.sharedInstance.newRealm()
        let predicate = NSPredicate(format: "\(SongData.Column.Tempo) BETWEEN {%f, %f}", tempo - 10, tempo + 10)
        let result = realm.objects(SongData).filter(predicate)
        return Array(result)
    }
    
    func loadListSongViewData() -> [SongViewData] {
        let songUtils = SongUtils()
        let listSongData = loadSongs()
        var listSongView = [SongViewData]()
        for song in listSongData {
            let songView = songUtils.songViewDataFromPersistentId(song.persistentId, analysisInfo: song)
            if (songView == nil) {
                continue
            }
            listSongView.append(songView!)
        }
        return listSongView
    }
    
    func deleteSong(_ persistentId: String) {
        let realm = RealmFactory.sharedInstance.newRealm()
        let objectToDelete = realm.object(ofType: SongData.self, forPrimaryKey: persistentId as AnyObject)
        if let obj = objectToDelete {
            realm.beginWrite()
            realm.delete(obj)
            try! realm.commitWrite()
        }
    }
}
