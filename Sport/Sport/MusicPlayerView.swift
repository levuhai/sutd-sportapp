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
    
    func switchControlMode(runningMode: Bool)
    
    func updatePlaybackProgress(progress: Double)
    
    func setTempoSliderValue(tempo: Float)
    
    func updateViewForPlayingState(isPlaying: Bool)
    
    func updateSongInfo(playerViewData: SongViewData?)
    
    func displayPlaylist(playlist: [SongViewData])
    func showPlayingSongInPlaylist(indexInPlaylist: Int)
    
    func updateActivityRatesData(data: Float)
    func updateStepCount(stepCount: Int)
}
