//
//  SPAudioPlayer.swift
//  Sport
//
//  Created by Tien on 5/30/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol SPAudioPlayerDelegate: class {
    func audioPlayerDidStartPlay(audioPlayer: SPAudioPlayer, song: SPPlayerItem)
    func audioPlayerDidPause(audioPlayer: SPAudioPlayer)
    func audioPlayerDidResume(audioPlayer: SPAudioPlayer)
    func audioPlayerDidStop(audioPlayer: SPAudioPlayer)
    func audioPlayerFailedToPlay(audioPlayer: SPAudioPlayer, song: SPPlayerItem)
    func audioPlayerDidReachEndOfPlaylist(audioPlayer: SPAudioPlayer)
}

class SPAudioPlayer: NSObject {
    
    enum SPAudioPlaybackState {
        case Stopped
        case Paused
        case Preparing
        case Playing
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
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: currentItem)
        }
        
        didSet {
            if (currentItem == nil) {
                return
            }
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SPAudioPlayer.playerItemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: currentItem)
        }
    }
    var observingObject: SPPlayerItem?
    
    // Events handler.
    var progressHandlerBlock: ((progress: Double)->())?
    
    var playbackState: SPAudioPlaybackState = .Stopped

    var seekTimer: NSTimer?
    /// =============================================================================
    //  Methods
    //
    
    func setup(songQueue: [SPPlayerItem]) {
        currentItem = nil
        
        playerItems = Array(songQueue)
    }
   
    // MARK: - Event listeners
    // Set progress listener
    func setProgressHandler(block: ((progress: Double)->())?) {
        progressHandlerBlock = block
    }
    
    // MARK: - Playback functions
    // Play current song currentItem
    func playPlayListFromStopped() {
        playbackState = .Preparing
        if (currentItem == nil) {
            currentItem = playerItems.first
            currentPlayingIndex = 0
        }
        playCurrentItem()
    }
    
    func playPlayListFromIndex(index: Int) {
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
        if playbackState == .Paused {
            resume()
        } else if playbackState == .Stopped {
            playPlayListFromStopped()
        }
    }
    
    func resume() {
        playbackState = .Playing
        thePlayer?.play()
        
        delegate?.audioPlayerDidResume(self)
    }
    
    func pause() {
        playbackState = .Paused
        thePlayer?.pause()
        
        delegate?.audioPlayerDidPause(self)
    }
    
    func stop() {
        playbackState = .Stopped
        detachListener(currentItem)
        thePlayer?.pause()
        currentItem = nil
        
        // call delegate
        delegate?.audioPlayerDidStop(self)
    }
    
    func moveToNext() {
        let shouldAutoPlay = playbackState == .Playing
        moveToNext(shouldAutoPlay)
    }
    
    func moveToPrevious() {
        let shouldAutoPlay = playbackState == .Playing
        moveToPrevious(shouldAutoPlay)
    }
    
    func moveToNext(autoPlay: Bool) {
        stop()
        next(autoPlay)
    }
    
    func next(autoPlay: Bool) {
        if let nextItem = nextPlayerItem() {
            currentPlayingIndex += 1
            currentItem = nextItem
            
            if (autoPlay) {
                playCurrentItem()
            }
        } else {
            playbackState = .Stopped
            didReachEndOfPlaylist()
        }
    }
    
    func previous(autoPlay: Bool) {
        if let previousItem = previousPlayerItem() {
            currentPlayingIndex -= 1
            currentItem = previousItem
            
            if (autoPlay) {
                playCurrentItem()
            }
        } else {
            playbackState = .Stopped
            didReachEndOfPlaylist()
        }
    }
    
    func moveToPrevious(autoPlay: Bool) {
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
            thePlayer?.replaceCurrentItemWithPlayerItem(currentItem)
        }
        thePlayer?.seekToTime(kCMTimeZero)
        
        attachListener(currentItem!)
        
        playbackState = .Playing
        thePlayer?.play()
        
        delegate?.audioPlayerDidStartPlay(self, song: currentItem!)
    }
   
    func rewind() {
        if playbackState == .Playing {
            seekTimer?.invalidate()
            seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SPAudioPlayer.moveRewind), userInfo: nil, repeats: true)
        }
    }
    
    func fastforward() {
        if playbackState == .Playing {
            seekTimer?.invalidate()
            seekTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SPAudioPlayer.moveFastForward), userInfo: nil, repeats: true)
        }
    }
    
    func moveFastForward() {
        guard let currentTime = thePlayer?.currentTime() else {
            return
        }
        
        let future = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime) + 5, currentTime.timescale)
        thePlayer?.seekToTime(future, completionHandler: { (success) in
            
        })
    }
    
    func moveRewind() {
        guard let currentTime = thePlayer?.currentTime() else {
            return
        }
        
        let future = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime) - 5, currentTime.timescale)
        thePlayer?.seekToTime(future, completionHandler: { (success) in
            
        })
    }
    
    func endSeek() {
        seekTimer?.invalidate()
    }
    
    func isPlaying() -> Bool {
        return playbackState == .Playing
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
    
    func playerItemDidFinishPlaying(notification: NSNotification) {
        print("Finished")
        seekTimer?.invalidate()
        stop()
        next(true)
    }
    
    func didReachEndOfPlaylist() {
        delegate?.audioPlayerDidReachEndOfPlaylist(self)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let item = object as? SPPlayerItem, let keyPath = keyPath where item == currentItem && keyPath == "status" {
            let status = item.status
            if status == .Failed {
                playbackState = .Stopped
                delegate?.audioPlayerFailedToPlay(self, song: item)
            }
        }
    }
}

extension SPAudioPlayer {
    
    // MARK: - Private methods.
    func attachListener(playerItem: SPPlayerItem) {
        registerForTimeTracking(progressHandlerBlock)
        playerItem.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        observingObject = playerItem
    }
    
    func detachListener(playerItem: SPPlayerItem?) {
        unregisterTimeTracking()
        observingObject?.removeObserver(self, forKeyPath: "status")
        observingObject = nil
    }
    
    func registerForTimeTracking(block: ((progress: Double)->())?) {
        if block == nil {
            return
        }
        
        let interval = CMTimeMake(5, 100) // 0.05 milisecond per update.
        playbackObserver = thePlayer?.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue(), usingBlock: { [unowned self] (cmTime) in
            let duration = self.currentPlayerItemDuration()
            if !CMTIME_IS_VALID(duration) {
                return
            }
            
            let currentTimeSecond = CMTimeGetSeconds(self.thePlayer!.currentTime())
            let durationInSecond = CMTimeGetSeconds(duration)
            if currentTimeSecond >= 0 && currentTimeSecond <= durationInSecond {
                block!(progress: currentTimeSecond/durationInSecond)
            }
        })
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
        if currentPlayerItem.status == .ReadyToPlay {
            return currentPlayerItem.duration
        }
        return kCMTimeInvalid
    }
    
    
}

extension