//
//  SongRealmRepository.swift
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SongRealmRepository: SongRepository {
    
    let songImporter: SongImporter!
    
    init(songImporter: SongImporter) {
        self.songImporter = songImporter
    }
    
    func addSong(song: SongData) {
        print("Song added \(song.persistentId), \(song.title)")
        
        RealmManager.sharedInstance.execute { (realm) in
            try! realm.write({
                realm.add(song)
            })
        }
    }
    
    func addSongs(songs: [SongData]) {
        
    }
    
    func loadSongsWithCompletion(completion: ((songs: [SongData]?, error: NSError?) -> Void)) {
        
    }
    
    func importSongsWithCompletion(completion: (() -> ())?) {
        songImporter.importToRepository(self) { 
            completion?()
        }
    }
    
    func isSongExisting(persistenceId: String) -> Bool {
        var isExisting = false
        RealmManager.sharedInstance.execute { (realm) in
            let predicate = NSPredicate(format: "\(SongData.Column.PersistentId) == %@", persistenceId)
            print(predicate)
            let songs = realm.objects(SongData).filter(predicate)
            isExisting = songs.count > 0
        }
        return isExisting
    }
}
