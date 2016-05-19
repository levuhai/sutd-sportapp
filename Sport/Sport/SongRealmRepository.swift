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
        print("Song added \(song.persistentId), \(song.tempo)")
        
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
}
