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
        audioPlayer.delegate = self
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
        if audioPlayer.playOrResume() {
            playerView?.updateViewForPlayingState(true)
        }
    }
    
    func audioDoPause() {
        audioPlayer.pause()
        playerView?.updateViewForPlayingState(false)
    }
    
    func audioDoStop() {
        audioPlayer.stop()
        playerView?.updateViewForPlayingState(false)
        playerView?.updatePlaybackProgress(0)
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
        playerView?.displayPlaylist(getPlaylistForDisplay(playList, currentPlayingItem: audioPlayer.currentItem))
    }
    
    func showCurrentSongInfo(playerItem: SPPlayerItem?) {
        guard let currentItem = playerItem else {
            // ??? What to do
            return
        }
        
        let currentSongViewData = songViewFromPlayerItem(currentItem)
        playerView?.updateSongInfo(currentSongViewData)
    }
    
    func getPlaylistForDisplay(playlist: [SPPlayerItem], currentPlayingItem: SPPlayerItem?) -> [SongViewData] {
        var listSongViews = [SongViewData]()
        for spItem in playlist {
            let songView = songViewFromPlayerItem(spItem)
            songView.isPlaying = spItem == currentPlayingItem
            listSongViews.append(songView)
        }
        return listSongViews
    }
    
    func songViewFromPlayerItem(playerItem: SPPlayerItem) -> SongViewData {
        let title = playerItem.mediaItem.title ?? "Unknown"
        let artist = playerItem.mediaItem.artist ?? "Unknown"
        let albumImage = playerItem.mediaItem.artwork?.imageWithSize(CGSizeMake(64, 64)) ?? UIImage(named: "unknown_album")
        return SongViewData(image: albumImage!, title: title, artist: artist, tempo: playerItem.tempo)
        
    }
}

extension MusicPlayerPresenterImpl: SPAudioPlayerDelegate {
    
    func audioPlayerReadyToPlay(audioPlayer: SPAudioPlayer, song: SPPlayerItem) {
        let currentItem = song
        
        var indexOfPlayingItem = -1
        for i in 0..<playList.count {
            let item = playList[i]
            if item == currentItem {
                indexOfPlayingItem = i
                break
            }
        }
        playerView?.showPlayingSong(indexOfPlayingItem)
    }
    
    func audioPlayerFailedToPlay(audioPlayer: SPAudioPlayer, song: SPPlayerItem) {
        
    }
    
    func audioPlayerDidReachEndOfPlaylist(audioPlayer: SPAudioPlayer) {
        audioDoStop()
        playerView?.showPlayingSong(-1)
    }
}
