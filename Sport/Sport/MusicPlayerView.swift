//
//  MusicPlayerView.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol MusicPlayerView: class {
    func initialize()
    
    func switchControlMode(_ runningMode: Bool)
    
    func updatePlaybackProgress(_ progress: Double)
    
    func setTempoSliderValue(_ tempo: Float)
    
    func updateViewForPlayingState(_ isPlaying: Bool)
    
    func updateSongInfo(_ playerViewData: SongViewData?)
    
    func displayPlaylist(_ playlist: [SongViewData])
    func showPlayingSongInPlaylist(_ indexInPlaylist: Int)
    
    func updateActivityRatesData(_ data: Float)
    func updateStepCount(_ stepCount: Int)
}
