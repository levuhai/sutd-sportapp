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
    let audioPlayer = SPAudioPlayer.sharedInstance
    
    var runningMode = false
    var playList: [SPPlayerItem] = []
    
    init(musicView: MusicPlayerView, router: MusicPlayerRouter, songRepository: SongRepository) {
        self.playerView = musicView
        self.router = router
        self.songRepository = songRepository
        
        super.init()
    }
    
    func initialize() {
        playerView?.initialize()
        
        let audioPlayer = SPAudioPlayer.sharedInstance
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
        audioPlayer.moveToPrevious()
        showCurrentSongInfo(audioPlayer.currentItem)
    }
    
    func onFastForwardButtonClicked() {
        audioPlayer.moveToNext()
        showCurrentSongInfo(audioPlayer.currentItem)
    }
    
    func onPlayPauseButonClicked() {
        
        if audioPlayer.isPlaying() {
            audioDoPause()
        } else {
            audioDoPlay()
        }
        showCurrentSongInfo(audioPlayer.currentItem)
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
    
    func audioDoStop() {
        audioPlayer.stop()
        playerView?.updateViewForPlayingState(false)
    }
    
    func loadSongs(tempo: Float) {
        let songs = songRepository.loadSongs(tempo)
        playList.removeAll()
        
        let adapter = SPPlayerItemAdapter()
        playList = adapter.createPlayerItems(songs)
    }
    
    func setupNewPlayList() {
        audioDoStop()
        audioPlayer.setup(playList)
    }
    
    func showCurrentSongInfo(playerItem: SPPlayerItem?) {
        guard let currentItem = playerItem else {
            // ??? What to do
            return
        }
        
        let title = currentItem.mediaItem.title ?? "Unknown"
        let artist = currentItem.mediaItem.artist ?? "Unknown"
        let albumImage = currentItem.mediaItem.artwork?.imageWithSize(CGSizeMake(64, 64)) ?? UIImage(named: "unknown_album")
        playerView?.updateSongInfo(title, tempo: currentItem.tempo, artist: artist, albumImage: albumImage!)
    }
}

