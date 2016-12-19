//
//  SongRepository.swift
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol SongRepository: class {
    func addSongs(_ songs: [SongData])
    func addSong(_ song: SongData)
    
    func loadSongs() -> [SongData]
    
    func isSongExisting(_ persistenceId: String) -> Bool
    
    func loadSongs(_ tempo: Float, _ energy: Float, _ valence: Float) -> [SongData]
    
    func deleteSong(_ persistentId: String)
    
    func loadListSongViewData() -> [SongViewData]
}
