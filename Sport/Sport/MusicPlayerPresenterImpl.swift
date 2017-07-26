//
//  MusicPlayerPresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import CoreMotion

class MusicPlayerPresenterImpl: NSObject, MusicPlayerPresenter {
    weak var playerView: MusicPlayerView?
    let router: MusicPlayerRouter
    var songRepository: SongRepository
    let audioPlayer = SPAudioPlayer.sharedInstance
    var runningMode = false
    var lastSPM: Float = 0.0
    var playList: [SPPlayerItem] = []
    
    let pedometer = SPPedometer()
    
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
        
        // Query las tempo data
        let savedTempo = AppUserDefaults.lastTempo() ?? Constants.Defaults.tempoMin
        playerView?.setTempoSliderValue(savedTempo)
        
        let savedEngery = AppUserDefaults.lastEnergy() ?? Constants.Defaults.energyMin
        let savedValence = AppUserDefaults.lastValence() ?? Constants.Defaults.valenceMin
        playerView?.setTrackPadValue(savedEngery, savedValence)
        
        loadSongs(AppUserDefaults.tempo, AppUserDefaults.energy, AppUserDefaults.valence)
        
        setupNewPlayList()
    }
    
    func onLeftBarButtonClicked() {
        router.navigateToLibraryScreen()
    }
    
    func onRightBarButtonClicked() {
        runningMode = !runningMode
        playerView?.switchControlMode(runningMode)
        
        if runningMode {
            
            // TODO: Start step counter here and update total steps in the handler.
             
             pedometer.startPedometerWithUpdateInterval(1/60.0, handler: { [weak self] (totalSteps, stepsPerSecond) in
                self?.playerView?.updateStepCount(totalSteps)
                var tempo:Float = stepsPerSecond*60
                self?.playerView?.updateStepsPerMinute(tempo)
                if (tempo == 0.0) {
                    self?.audioDoStop()
                } else {
                    if (tempo < 70.0) {
                        tempo = 45.0
                    } else if (tempo >= 70.0 && tempo < 130.0) {
                        tempo = 105.0
                    } else {
                        tempo = 145.0
                    }
                    if (tempo != self?.lastSPM) {
                        self?.loadSongs(tempo, AppUserDefaults.energy, AppUserDefaults.valence)
                        
                        self?.playerView?.updateSongInfo(nil)
                        self?.setupNewPlayList()
                        self?.onPlayPauseButonClicked()
                    }
                }
                self?.lastSPM = tempo
             })
            
            pedometer.startActivityUpdate({ [weak self] (activityStr) in
                self?.playerView?.updateActivityImage(activityStr)
            })
            
        } else {
            pedometer.stopStepCounter()
        }
    }
    
    func onRewindButtonClicked() {
        audioPlayer.moveToPrevious()
        showCurrentSongInfo(audioPlayer.currentItem)
    }
    
    func onFastForwardButtonClicked() {
        audioPlayer.moveToNext()
        showCurrentSongInfo(audioPlayer.currentItem)
    }
    
    func onFastForwardStarted() {
        audioPlayer.fastforward()
    }
    
    func onFastForwardEnded() {
        audioPlayer.endSeek()
    }
    
    func onRewindStarted() {
        audioPlayer.rewind()
    }
    
    func onRewindEnded() {
        audioPlayer.endSeek()
    }
    
    func onPlayPauseButonClicked() {
        if audioPlayer.isPlaying() {
            audioDoPause()
        } else {
            audioDoPlay()
        }
    }
    
    func onTempoSliderValueChanged(_ newValue: Float) {
        AppUserDefaults.saveLastTempo(newValue)
        
        loadSongs(AppUserDefaults.tempo, AppUserDefaults.energy, AppUserDefaults.valence)
        
        playerView?.updateSongInfo(nil)
        setupNewPlayList()
        self.onPlayPauseButonClicked()
    }
    
    func onTrackPadValueChanged(_ eValue: Float, _ vValue: Float) {
        AppUserDefaults.saveLastEnergy(eValue)
        AppUserDefaults.saveLastValence(vValue)
        
        loadSongs(AppUserDefaults.tempo, AppUserDefaults.energy, AppUserDefaults.valence)
        
        playerView?.updateSongInfo(nil)
        setupNewPlayList()
        print(AppUserDefaults.tempo)
        self.onPlayPauseButonClicked()
    }
    
    func playlistDidSelectItemAtIndex(_ indexPath: IndexPath) {
        audioPlayer.playPlayListFromIndex((indexPath as NSIndexPath).row)
    }
}

extension MusicPlayerPresenterImpl: SPAudioPlayerDelegate {
    
    func audioPlayerDidStartPlay(_ audioPlayer: SPAudioPlayer, song: SPPlayerItem) {
        playerView?.updatePlaybackProgress(0)
        
        let currentItem = song
        
        var indexOfPlayingItem = -1
        for i in 0..<playList.count {
            let item = playList[i]
            if item == currentItem {
                indexOfPlayingItem = i
                break
            }
        }
        playerView?.showPlayingSongInPlaylist(indexOfPlayingItem)
        showCurrentSongInfo(song)
        playerView?.updateViewForPlayingState(true)
    }
    
    func audioPlayerDidStop(_ audioPlayer: SPAudioPlayer) {
        playerView?.updateViewForPlayingState(false)
        playerView?.updatePlaybackProgress(0)
    }
    
    func audioPlayerDidPause(_ audioPlayer: SPAudioPlayer) {
        playerView?.updateViewForPlayingState(false)
    }
    
    func audioPlayerDidResume(_ audioPlayer: SPAudioPlayer) {
        playerView?.updateViewForPlayingState(true)
    }
    
    func audioPlayerFailedToPlay(_ audioPlayer: SPAudioPlayer, song: SPPlayerItem) {
        
    }
    
    func audioPlayerDidReachEndOfPlaylist(_ audioPlayer: SPAudioPlayer) {
        audioDoStop()
        playerView?.showPlayingSongInPlaylist(-1)
    }
}

extension MusicPlayerPresenterImpl: SPActivityRateViewDataSource {
    func dataForActivityRateView(_ view: SPActivityRateView) -> Float {
//        let nilableAccelerometerData = motionManager.accelerometerData
//        
//        guard let accelerometerData = nilableAccelerometerData, let lastAccelerometerData = self.lastAccelerometerData else {
//            self.lastAccelerometerData = nilableAccelerometerData
//            return Float(1.0)
//        }
//        
//        let dValue = calculateDValue(accelerometerData, lastAccel: lastAccelerometerData)
//        self.lastAccelerometerData = accelerometerData
//        storeDvalue(dValue, dvaltable: &self.dvalArray)
//        return Float(dValue)
        return Float (pedometer.stepsPerSecond*60)
        
    }    
}

extension MusicPlayerPresenterImpl {
    
    func setupNewPlayList() {
        audioDoStop()
        audioPlayer.setup(playList)
        playerView?.displayPlaylist(getPlaylistForDisplay(playList, currentPlayingItem: audioPlayer.currentItem))
    }
    
    func showCurrentSongInfo(_ playerItem: SPPlayerItem?) {
        guard let currentItem = playerItem else {
            // ??? What to do if current item is nil 
            return
        }
        
        let currentSongViewData = songViewFromPlayerItem(currentItem)
        playerView?.updateSongInfo(currentSongViewData)
    }
    
    func getPlaylistForDisplay(_ playlist: [SPPlayerItem], currentPlayingItem: SPPlayerItem?) -> [SongViewData] {
        var listSongViews = [SongViewData]()
        for spItem in playlist {
            let songView = songViewFromPlayerItem(spItem)
            songView.isPlaying = spItem == currentPlayingItem
            listSongViews.append(songView)
        }
        return listSongViews
    }
    
    func songViewFromPlayerItem(_ playerItem: SPPlayerItem) -> SongViewData {
        let title = playerItem.mediaItem.title ?? Localizations.UnknownArtist
        let artist = playerItem.mediaItem.artist ?? Localizations.UnknownTitle
        let albumImage = playerItem.mediaItem.artwork?.image(at: CGSize(width: 64, height: 64)) ?? #imageLiteral(resourceName: "unknown_album")
        return SongViewData(image: albumImage, title: title, artist: artist, tempo: playerItem.tempo, energy: playerItem.energy, happiness: playerItem.valence)
        
    }
    
    func audioDoPlay() {
        audioPlayer.play()
    }
    
    func audioDoPause() {
        audioPlayer.pause()
    }
    
    func audioDoStop() {
        audioPlayer.stop()
    }
    
    func loadSongs(_ tempo: Float, _ energy: Float, _ valence: Float) {
        let songs = songRepository.loadSongs(tempo, energy, valence)
        playList.removeAll()
        
        let adapter = SPPlayerItemAdapter()
        playList = adapter.createPlayerItems(songs)
    }

}

