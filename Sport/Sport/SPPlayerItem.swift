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
    
    init(asset: AVAsset, mediaItem: MPMediaItem, tempo: Float) {
        self.mediaItem = mediaItem
        self.tempo = tempo
        super.init(asset: asset, automaticallyLoadedAssetKeys: [ "duration" ])
    }
    
}