//
//  SPPlayerItemAdapter.swift
//  Sport
//
//  Created by Tien on 6/2/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class SPPlayerItemAdapter: NSObject {
    
    // Create list of playerItems from list of song's persistent ids.
    func createPlayerItems(songData: [SongData]) -> [SPPlayerItem] {
        var playerItems: [SPPlayerItem] = []
        for song in songData {
            let persistentId = song.persistentId
            
            // make sure the song with that id is currently exist.
            let mediaItem = MPMediaItemFromPersistentId(persistentId)
            if mediaItem == nil {
                continue
            }
            // Make sure that media item is local file (has avassetURL)
            let avasset = AVAssetFromMPMediaItem(mediaItem!)
            if avasset == nil {
                continue
            }
            
            let playerItem = SPPlayerItem(asset: avasset!, mediaItem: mediaItem!, tempo: Float(song.tempo), energy: Float(song.energy))
            playerItems.append(playerItem)
        }
        return playerItems
    }
    
    private func AVAssetFromMPMediaItem(mediaItem: MPMediaItem) -> AVAsset? {
        guard let assetURL = mediaItem.assetURL else {
            return nil
        }
        return AVURLAsset(URL: assetURL)
    }
    
    // Get media item from persistentId.
    private func MPMediaItemFromPersistentId(persistentId: String) -> MPMediaItem? {
        let query = MPMediaQuery.songsQuery()
        let predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyPersistentID)
        query.addFilterPredicate(predicate)
        return query.items?.first
    }
}
