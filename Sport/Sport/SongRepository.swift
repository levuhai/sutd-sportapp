//
//  SongRepository.swift
//  Sport
//
//  Created by Tien on 5/16/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol SongRepository: class {
    func addSongs(songs: [SongData])
    func addSong(song: SongData)
    
    func loadSongs() -> [SongData]
    
    func isSongExisting(persistenceId: String) -> Bool
}
