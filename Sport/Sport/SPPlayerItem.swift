//
//  SPPlayerItem.swift
//  Sport
//
//  Created by Tien on 6/1/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import MediaPlayer

class SPPlayerItem: AVPlayerItem {
    let mediaItem: MPMediaItem
    let tempo: Float
    let energy: Float
    let valence: Float
    
    init(asset: AVAsset, mediaItem: MPMediaItem, tempo: Float, energy: Float, valence: Float) {
        self.mediaItem = mediaItem
        self.tempo = tempo
        self.energy = energy
        self.valence = valence
        super.init(asset: asset, automaticallyLoadedAssetKeys: [ "duration" ])
    }
    
}
