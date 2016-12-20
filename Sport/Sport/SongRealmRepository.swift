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
        let result = realm.objects(SongData.self)
        return Array(result)
    }
    
    func loadSongs(_ tempo: Float, _ energy: Float, _ valence: Float) -> [SongData] {
        let realm = RealmFactory.sharedInstance.newRealm()
        // Energy calculate
        let eScale = (Constants.Defaults.energyMax - Constants.Defaults.energyMin)/3
        let scale1 = Constants.Defaults.energyMin + eScale
        let scale2 = Constants.Defaults.energyMax - eScale;
        var eHigh: Float = scale2
        var eLow: Float = scale1
        if (energy < scale1) {
            eHigh = scale1
            eLow = Constants.Defaults.energyMin
        } else if (energy > scale2) {
            eHigh = Constants.Defaults.energyMax
            eLow = scale2
        }
        // Valence calculate
        let vScale = (Constants.Defaults.valenceMax - Constants.Defaults.valenceMin)/3
        let scale3 = Constants.Defaults.valenceMin + vScale
        let scale4 = Constants.Defaults.valenceMax - vScale;
        var vHigh: Float = scale4
        var vLow: Float = scale3
        if (valence < scale3) {
            vHigh = scale3
            vLow = Constants.Defaults.valenceMin
        } else if (valence > scale4) {
            vHigh = Constants.Defaults.valenceMax
            vLow = scale4
        }
        
        let predicate = NSPredicate(format: "\(SongData.Column.Tempo) BETWEEN {%f, %f} AND \(SongData.Column.Energy) BETWEEN {%f, %f} AND \(SongData.Column.Valence) BETWEEN {%f, %f}", tempo - 30, tempo + 30, eLow, eHigh, vLow, vHigh)
        let result = realm.objects(SongData.self).filter(predicate)
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
