
//
//  SongViewData.swift
//  Sport
//
//  Created by Tien on 6/5/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SongViewData: NSObject {
    let image: UIImage
    let title: String
    let artist: String
    var isPlaying: Bool
    
    // Technical info
    let tempo: Float
    let energy: Float
    
    init(image: UIImage, title: String, artist: String, tempo: Float, isPlaying: Bool = false, energy: Float) {
        self.image = image
        self.title = title
        self.artist = artist
        self.isPlaying = isPlaying
        self.tempo = tempo
        self.energy = energy
    }
}
