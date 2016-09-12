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
    
    let rightLegThreshold = 0.96
    let leftLegThreshold = 0.96
    
    var stepCount = 0
    weak var playerView: MusicPlayerView?
    let router: MusicPlayerRouter
    var songRepository: SongRepository
    let audioPlayer = SPAudioPlayer.sharedInstance
    let motionManager = CMMotionManager()
    
    var runningMode = false
    var playList: [SPPlayerItem] = []
    
    var lastAccelerometerData: CMAccelerometerData? = nil
    var lastAccelerometerDataStepTracking: CMAccelerometerData? = nil
    var dvalArray = [Double]()
    
    let pedometer = SPPedometer()
    
    var stepTimer: NSTimer?
    
    init(musicView: MusicPlayerView, router: MusicPlayerRouter, songRepository: SongRepository) {
        self.playerView = musicView
        self.router = router
        self.songRepository = songRepository
        
        super.init()
    }
    
    func initialize() {
        setupMotionManager()
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
        
        if !motionManager.accelerometerAvailable {
            return
        }
        if runningMode {
            motionManager.startAccelerometerUpdates()
            // TODO: Start step counter here and update total steps in the handler.
            /*
             
             pedometer.startPedometerWithUpdateInterval(1, handler: { [weak self] (totalSteps) in
                self?.playerView?.updateStepCount(totalSteps)
             })
             
             */
            stepTimer?.invalidate()
            stepTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateTotalStep), userInfo: nil, repeats: true)
        } else {
            motionManager.stopAccelerometerUpdates()
            // TODO: Stop step counter.
//            pedometer.stopStepCounter()
            stepTimer?.invalidate()
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
    
    func onTempoSliderValueChanged(newValue: Float) {
        AppUserDefaults.saveLastTempo(newValue)
        
        loadSongs(newValue)
        
        playerView?.updateSongInfo(nil)
        setupNewPlayList()
    }
    
    func playlistDidSelectItemAtIndex(indexPath: NSIndexPath) {
        audioPlayer.playPlayListFromIndex(indexPath.row)
    }
}

extension MusicPlayerPresenterImpl: SPAudioPlayerDelegate {
    
    func audioPlayerDidStartPlay(audioPlayer: SPAudioPlayer, song: SPPlayerItem) {
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
    
    func audioPlayerDidStop(audioPlayer: SPAudioPlayer) {
        playerView?.updateViewForPlayingState(false)
        playerView?.updatePlaybackProgress(0)
    }
    
    func audioPlayerDidPause(audioPlayer: SPAudioPlayer) {
        playerView?.updateViewForPlayingState(false)
    }
    
    func audioPlayerDidResume(audioPlayer: SPAudioPlayer) {
        playerView?.updateViewForPlayingState(true)
    }
    
    func audioPlayerFailedToPlay(audioPlayer: SPAudioPlayer, song: SPPlayerItem) {
        
    }
    
    func audioPlayerDidReachEndOfPlaylist(audioPlayer: SPAudioPlayer) {
        audioDoStop()
        playerView?.showPlayingSongInPlaylist(-1)
    }
}

extension MusicPlayerPresenterImpl: SPActivityRateViewDataSource {
    func dataForActivityRateView(view: SPActivityRateView) -> Float {
        let nilableAccelerometerData = motionManager.accelerometerData
        
        guard let accelerometerData = nilableAccelerometerData, lastAccelerometerData = self.lastAccelerometerData else {
            self.lastAccelerometerData = nilableAccelerometerData
            return Float(1.0)
        }
        
        let dValue = calculateDValue(accelerometerData, lastAccel: lastAccelerometerData)
        self.lastAccelerometerData = accelerometerData
        storeDvalue(dValue, dvaltable: &self.dvalArray)
        
        return Float(dValue)
    }
    
    func updateTotalStep() {
//        let nilableAccelerometerData = motionManager.accelerometerData
//        
//        guard let accelerometerData = nilableAccelerometerData, lastAccelerometerData = self.lastAccelerometerDataStepTracking else {
//            self.lastAccelerometerDataStepTracking = nilableAccelerometerData
//            return
//        }
//        
//        let dValue = calculateDValue(accelerometerData, lastAccel: lastAccelerometerData)
//        self.lastAccelerometerDataStepTracking = accelerometerData
//        storeDvalue(dValue, dvaltable: &self.dvalArray)
        let wma = self.calculateWMA(self.dvalArray)
        if (wma < rightLegThreshold) {
            stepCount += 1
        }
        
        playerView?.updateStepCount(stepCount)
    }
    
    func calculateDValue(currentAccel: CMAccelerometerData, lastAccel: CMAccelerometerData) -> Double {
        
        let x = currentAccel.acceleration.x
        let y = currentAccel.acceleration.y
        let z = currentAccel.acceleration.z
        
        let x0 = lastAccel.acceleration.x
        let y0 = lastAccel.acceleration.y
        let z0 = lastAccel.acceleration.z
        
        let d = (x*x0 + y*y0 + z*z0) / sqrt((x*x + y*y + z*z) * (x0*x0 + y0*y0 + z0*z0));
        return d
    }
    
    func calculateWMA(dvaltable: [Double]) -> Double {
        var sum: Double = 0
        var factor: Double = 60
        
        for index in (0..<dvaltable.count).reverse() {
            sum += factor * dvaltable[index]
            factor -= 1
        }
        return sum / 1830.0
    }
    
    func storeDvalue(value: Double, inout dvaltable: [Double]) {
        if (dvaltable.count > 60) {
            dvaltable.removeFirst()
        }
        dvaltable.append(value)
    }
}

extension MusicPlayerPresenterImpl {
    
    func setupNewPlayList() {
        audioDoStop()
        audioPlayer.setup(playList)
        playerView?.displayPlaylist(getPlaylistForDisplay(playList, currentPlayingItem: audioPlayer.currentItem))
    }
    
    func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 1.0/60
        print("Accelerometer interval: \(motionManager.accelerometerUpdateInterval)")
    }
    
    func showCurrentSongInfo(playerItem: SPPlayerItem?) {
        guard let currentItem = playerItem else {
            // ??? What to do if current item is nil 
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
        let title = playerItem.mediaItem.title ?? Localizations.UnknownArtist
        let artist = playerItem.mediaItem.artist ?? Localizations.UnknownTitle
        let albumImage = playerItem.mediaItem.artwork?.imageWithSize(CGSizeMake(64, 64)) ?? UIImage(named: "unknown_album")
        return SongViewData(image: albumImage!, title: title, artist: artist, tempo: playerItem.tempo)
        
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
    
    func loadSongs(tempo: Float) {
        let songs = songRepository.loadSongs(tempo)
        playList.removeAll()
        
        let adapter = SPPlayerItemAdapter()
        playList = adapter.createPlayerItems(songs)
    }

}

