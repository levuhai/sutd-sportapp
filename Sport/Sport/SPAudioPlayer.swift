//
//  SPAudioPlayer.swift
//  Sport
//
//  Created by Tien on 5/30/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import AVFoundation
import MediaPlayer

protocol SPAudioPlayerDelegate: class {
    func audioPlayerDidStartPlay(_ audioPlayer: SPAudioPlayer, song: SPPlayerItem)
    func audioPlayerDidPause(_ audioPlayer: SPAudioPlayer)
    func audioPlayerDidResume(_ audioPlayer: SPAudioPlayer)
    func audioPlayerDidStop(_ audioPlayer: SPAudioPlayer)
    func audioPlayerFailedToPlay(_ audioPlayer: SPAudioPlayer, song: SPPlayerItem)
    func audioPlayerDidReachEndOfPlaylist(_ audioPlayer: SPAudioPlayer)
}

class SPAudioPlayer: NSObject {
    
    enum SPAudioPlaybackState {
        case stopped
        case paused
        case preparing
        case playing
    }
    
    // Shared instance.
    static let sharedInstance = SPAudioPlayer()
    
    weak var delegate: SPAudioPlayerDelegate?
    
    // Instance variables
    var thePlayer: AVPlayer?
    var playbackObserver: AnyObject?
    
    var playerItems: [SPPlayerItem] = []
    var currentPlayingIndex = 0
    var currentItem: SPPlayerItem? {
        willSet {
            if (currentItem == nil) {
                return
            }
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
        
        didSet {
            if (currentItem == nil) {
                return
            }
            NotificationCenter.default.addObserver(self, selector: #selector(SPAudioPlayer.playerItemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
    }
    var observingObject: SPPlayerItem?
    
    // Events handler.
    var progressHandlerBlock: ((_ progress: Double)->())?
    
    var playbackState: SPAudioPlaybackState = .stopped

    var seekTimer: Timer?
    /// =============================================================================
    //  Methods
    //
    
    func setup(_ songQueue: [SPPlayerItem]) {
        currentItem = nil
        
        playerItems = Array(songQueue)
    }
   
    // MARK: - Event listeners
    // Set progress listener
    func setProgressHandler(_ block: ((_ progress: Double)->())?) {
        progressHandlerBlock = block
    }
    
    // MARK: - Playback functions
    // Play current song currentItem
    func playPlayListFromStopped() {
        playbackState = .preparing
        if (currentItem == nil) {
            currentItem = playerItems.first
            currentPlayingIndex = 0
        }
        playCurrentItem()
    }
    
    func playPlayListFromIndex(_ index: Int) {
        stop()
        if index > playerItems.count {
            return
        }
        
        let choosenSong = playerItems[index]
        currentItem = choosenSong
        currentPlayingIndex = index
        
        playCurrentItem()
    }
    
    func play() {
        if playbackState == .paused {
            resume()
        } else if playbackState == .stopped {
            playPlayListFromStopped()
        }
    }
    
    func resume() {
        playbackState = .playing
        thePlayer?.play()
        
        delegate?.audioPlayerDidResume(self)
    }
    
    func pause() {
        playbackState = .paused
        thePlayer?.pause()
        
        delegate?.audioPlayerDidPause(self)
    }
    
    func stop() {
        playbackState = .stopped
        detachListener(currentItem)
        thePlayer?.pause()
        currentItem = nil
        
        // call delegate
        delegate?.audioPlayerDidStop(self)
    }
    
    func moveToNext() {
        let shouldAutoPlay = playbackState == .playing
        moveToNext(shouldAutoPlay)
    }
    
    func moveToPrevious() {
        let shouldAutoPlay = playbackState == .playing
        moveToPrevious(shouldAutoPlay)
    }
    
    func moveToNext(_ autoPlay: Bool) {
        stop()
        next(autoPlay)
    }
    
    func next(_ autoPlay: Bool) {
        if let nextItem = nextPlayerItem() {
            currentPlayingIndex += 1
            currentItem = nextItem
            
            if (autoPlay) {
                playCurrentItem()
            }
        } else {
            playbackState = .stopped
            didReachEndOfPlaylist()
        }
    }
    
    func previous(_ autoPlay: Bool) {
        if let previousItem = previousPlayerItem() {
            currentPlayingIndex -= 1
            currentItem = previousItem
            
            if (autoPlay) {
                playCurrentItem()
            }
        } else {
            playbackState = .stopped
            didReachEndOfPlaylist()
        }
    }
    
    func moveToPrevious(_ autoPlay: Bool) {
        stop()
        previous(autoPlay)
    }
    
    func playCurrentItem() {
        if (currentItem == nil) {
            return
        }
        
        if (thePlayer == nil) {
            thePlayer = AVPlayer(playerItem: currentItem!)
        } else {
            thePlayer?.replaceCurrentItem(with: currentItem)
        }
        thePlayer?.seek(to: kCMTimeZero)
        
        attachListener(currentItem!)
        
        playbackState = .playing
        thePlayer?.play()
        
        delegate?.audioPlayerDidStartPlay(self, song: currentItem!)
        configureNowPlayingInfo()
    }
   
    func rewind() {
        if playbackState == .playing {
            seekTimer?.invalidate()
            seekTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SPAudioPlayer.moveRewind), userInfo: nil, repeats: true)
        }
    }
    
    func fastforward() {
        if playbackState == .playing {
            seekTimer?.invalidate()
            seekTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SPAudioPlayer.moveFastForward), userInfo: nil, repeats: true)
        }
    }
    
    func moveFastForward() {
        guard let currentTime = thePlayer?.currentTime() else {
            return
        }
        
        let future = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime) + 5, currentTime.timescale)
        thePlayer?.seek(to: future, completionHandler: { (success) in
            
        })
    }
    
    func moveRewind() {
        guard let currentTime = thePlayer?.currentTime() else {
            return
        }
        
        let future = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime) - 5, currentTime.timescale)
        thePlayer?.seek(to: future, completionHandler: { (success) in
            
        })
    }
    
    func endSeek() {
        seekTimer?.invalidate()
    }
    
    func isPlaying() -> Bool {
        return playbackState == .playing
    }
    
    func nextPlayerItem() -> SPPlayerItem? {
        if (currentPlayingIndex + 1 >= playerItems.count) {
            return nil
        }
        return playerItems[currentPlayingIndex + 1]
    }
    
    func previousPlayerItem() -> SPPlayerItem? {
        if (currentPlayingIndex <= 0) {
            return nil
        }
        return playerItems[currentPlayingIndex - 1]
    }
    
    func playerItemDidFinishPlaying(_ notification: Notification) {
        print("Finished")
        seekTimer?.invalidate()
        stop()
        next(true)
    }
    
    func didReachEndOfPlaylist() {
        delegate?.audioPlayerDidReachEndOfPlaylist(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item = object as? SPPlayerItem, let keyPath = keyPath , item == currentItem && keyPath == "status" {
            let status = item.status
            if status == .failed {
                playbackState = .stopped
                delegate?.audioPlayerFailedToPlay(self, song: item)
            }
        }
    }
}

extension SPAudioPlayer {
    
    // MARK: - Private methods.
    func attachListener(_ playerItem: SPPlayerItem) {
        registerForTimeTracking(progressHandlerBlock)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        observingObject = playerItem
    }
    
    func detachListener(_ playerItem: SPPlayerItem?) {
        unregisterTimeTracking()
        observingObject?.removeObserver(self, forKeyPath: "status")
        observingObject = nil
    }
    
    func registerForTimeTracking(_ block: ((_ progress: Double)->())?) {
        if block == nil {
            return
        }
        
        let interval = CMTimeMake(5, 100) // 0.05 milisecond per update.
        playbackObserver = thePlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [unowned self] (cmTime) in
            let duration = self.currentPlayerItemDuration()
            if !CMTIME_IS_VALID(duration) {
                return
            }
            
            let currentTimeSecond = CMTimeGetSeconds(self.thePlayer!.currentTime())
            let durationInSecond = CMTimeGetSeconds(duration)
            if currentTimeSecond >= 0 && currentTimeSecond <= durationInSecond {
                block!(currentTimeSecond/durationInSecond)
            }
        }) as AnyObject?
    }
    
    func unregisterTimeTracking() {
        if playbackObserver != nil {
            thePlayer?.removeTimeObserver(playbackObserver!)
            playbackObserver = nil
        }
    }
    
    func currentPlayerItemDuration() -> CMTime {
        guard let currentPlayerItem = thePlayer?.currentItem else {
            return kCMTimeInvalid
        }
        if currentPlayerItem.status == .readyToPlay {
            return currentPlayerItem.duration
        }
        return kCMTimeInvalid
    }
}

// Show playing item on lock screen.
extension SPAudioPlayer {
    func configureNowPlayingInfo() {
        let mediaItem = currentItem!.mediaItem
        let infoCenter = MPNowPlayingInfoCenter.default()
        let songInfo: [String: AnyObject?]?
        
        if (mediaItem.artwork != nil) {
        //var newInfo = [String: AnyObject]()
            songInfo = [
                MPMediaItemPropertyTitle: mediaItem.title as AnyObject,
                MPMediaItemPropertyArtist: mediaItem.artist as AnyObject,
                MPMediaItemPropertyArtwork: mediaItem.artwork,
                MPMediaItemPropertyPlaybackDuration: mediaItem.playbackDuration as AnyObject
                
            ]
        } else {
            songInfo = [
                MPMediaItemPropertyTitle: mediaItem.title as AnyObject,
                MPMediaItemPropertyArtist: mediaItem.artist as AnyObject,
                //MPMediaItemPropertyArtwork: mediaItem.artwork,
                MPMediaItemPropertyPlaybackDuration: mediaItem.playbackDuration as AnyObject
                
            ]
        }
        
//        let itemProperties = Set([MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPMediaItemPropertyAlbumTitle, MPNowPlayingInfoPropertyElapsedPlaybackTime])
//        mediaItem.enumerateValues(forProperties: itemProperties) { (property, value, stop) in
//            newInfo[property] = value as AnyObject?
//        }
        
        infoCenter.nowPlayingInfo = songInfo
    }
}
