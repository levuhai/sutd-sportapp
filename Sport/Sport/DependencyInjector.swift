//
//  DependencyInjector.swift
//  Sport
//
//  Created by Tien on 6/5/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class DependencyInjector: NSObject {
    class func dummyPlaylistToView() -> [SongViewData] {
        var result = [SongViewData]()
        let unknownAlbumImage = UIImage(named: "unknown_album")
        for index in 1..<20 {
            result.append(SongViewData(image: unknownAlbumImage!, title: "Song \(index)", artist: "Unknown album", tempo: 0, isPlaying: index == 5))
        }
        return result
    }
}
