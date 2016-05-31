//
//  MusicPlayerPresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicPlayerPresenterImpl: NSObject, MusicPlayerPresenter {
    
    weak var playerView: MusicPlayerView?
    let router: MusicPlayerRouter
    var songRepository: SongRepository
    let audioPlayer = AudioPlayer.sharedInstance
    
    var runningMode = false
    var playList: [String] = []
    
    init(musicView: MusicPlayerView, router: MusicPlayerRouter, songRepository: SongRepository) {
        self.playerView = musicView
        self.router = router
        self.songRepository = songRepository
        
        super.init()
    }
    
    func initialize() {
        playerView?.initialize()
        
        let audioPlayer = AudioPlayer.sharedInstance
        audioPlayer.setProgressHandler { [unowned self] (progress) in
            self.playerView?.updatePlaybackProgress(progress)
        }
        
        let savedTempo = AppUserDefaults.lastTempo() ?? Constants.Defaults.tempoMin
        playerView?.setTempoSliderValue(savedTempo)
        
        loadSongs(savedTempo)
        
        setupNewPlayList()
    }
    
    
    
    func onLeftBarButtonClicked() {
        router.navigateToLibraryScreen()
    }
    
    func onRightBarButtonClicked() {
        runningMode = !runningMode
        playerView?.switchControlMode(runningMode)
    }
    
    func onRewindButtonClicked() {
        
    }
    
    func onFastForwardButtonClicked() {
        
    }
    
    func onPlayPauseButonClicked() {
        if audioPlayer.isPlaying() {
            audioDoPause()
        } else {
            audioDoPlay()
        }
    }
    
    func onTempoSliderValueChanged(newValue: Float) {
        AppUserDefaults.saveLastTempo(newValue)
        
        loadSongs(newValue)
        
        setupNewPlayList()
    }
    
    func audioDoPlay() {
        if audioPlayer.playbackState == .Paused {
            audioPlayer.resume()
        } else if audioPlayer.playbackState == .Stopped {
            audioPlayer.play()
        }
        playerView?.updateViewForPlayingState(true)
    }
    
    func audioDoPause() {
        audioPlayer.pause()
        playerView?.updateViewForPlayingState(false)
    }
    
    func loadSongs(tempo: Float) {
        let songs = songRepository.loadSongs(tempo)
        playList.removeAll()
        for song in songs {
            playList.append(song.persistentId)
        }
    }
    
    func setupNewPlayList() {
        audioDoPause()
        audioPlayer.setup(playList)
    }
}

