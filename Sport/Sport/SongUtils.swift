//
//  SongUtils.swift
//  Sport
//
//  Created by Tien on 6/9/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import MediaPlayer

class SongUtils: NSObject {
    
    // Get media item from persistentId.
    func MPMediaItemFromPersistentId(persistentId: String) -> MPMediaItem? {
        let query = MPMediaQuery.songsQuery()
        let predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyPersistentID)
        query.addFilterPredicate(predicate)
        return query.items?.first
    }
    
    func songViewDataFromPersistentId(persistentId: String, analysisInfo: SongData) -> SongViewData? {
        let mediaItem = MPMediaItemFromPersistentId(persistentId)
        guard let mpItem = mediaItem else {
            return nil
        }
        
        let title = mpItem.title ?? Localizations.UnknownTitle
        let artist = mpItem.artist ?? Localizations.UnknownArtist
        let albumImage = mpItem.artwork?.imageWithSize(CGSizeMake(64, 64)) ?? UIImage(named: "unknown_album")
        let tempo = Float(analysisInfo.tempo)
        let energy = Float(analysisInfo.energy)
        return SongViewData(image: albumImage!, title: title, artist: artist, tempo: tempo, energy: energy)
    }
}
