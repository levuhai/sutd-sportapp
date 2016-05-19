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
    func loadSongsWithCompletion(completion: ((songs: [SongData]?, error: NSError?) -> Void))
    
    func importSongsWithCompletion(completion: (()->())?)
}
