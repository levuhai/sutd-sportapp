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

enum SPAudioPlaybackState {
    case Stopped
    case Paused
    case Preparing
    case Playing
}

protocol SPAudioPlayerDelegate: class {
    func audioPlayerReadyToPlay(audioPlayer: SPAudioPlayer)
    func audioPlayerFailedToPlay(audioPlayer: SPAudioPlayer)
}

class SPAudioPlayer: NSObject {
    
    // Shared instance.
    static let sharedInstance = SPAudioPlayer()
    
    weak var delegate: SPAudioPlayerDelegate?
    
    // Instance variables
    var thePlayer: AVPlayer?
    var playbackObserver: AnyObject?
    
    var playerItems: [SPPlayerItem] = []
    var currentPlayingIndex = 0
    var currentItem: SPPlayerItem? {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SPAudioPlayer.playerItemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: currentItem)
        }
    }
    // Events handler.
    var progressHandlerBlock: ((progress: Double)->())?
    
    var playbackState: SPAudioPlaybackState = .Stopped

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
    func play() {
        playbackState = .Preparing
        if (currentItem == nil) {
            currentItem = playerItems.first
            currentPlayingIndex = 0
        }
        playCurrentItem()
    }
    
    func resume() {
        playbackState = .Playing
        thePlayer?.play()
    }
    
    func pause() {
        playbackState = .Paused
        thePlayer?.pause()
    }
    
    func stop() {
        playbackState = .Stopped
        detachListener(currentItem)
        thePlayer?.pause()
        currentItem = nil
    }
    
    func moveToNext() {
        let isPlaying = playbackState == .Playing
        stop()
        if let nextItem = nextPlayerItem() {
            currentPlayingIndex += 1
            currentItem = nextItem
            
            if (isPlaying) {
                playCurrentItem()
            }
        } else {
            playbackState = .Stopped
            didStoppedPlaying()
        }
    }
    
    func moveToPrevious() {
        let isPlaying = playbackState == .Playing
        stop()
        if let previousItem = previousPlayerItem() {
            currentPlayingIndex -= 1
            currentItem = previousItem
            
            if (isPlaying) {
                playCurrentItem()
            }
        } else {
            playbackState = .Stopped
            didStoppedPlaying()
        }
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
        moveToNext()
    }
    
    func didStartedPlaySong(song: SPPlayerItem) {
        
    }
    
    func didStoppedPlaying() {
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let item = object as? SPPlayerItem, let keyPath = keyPath where item == currentItem && keyPath == "status" {
            let status = item.status
            if status == .Failed {
                playbackState = .Stopped
                delegate?.audioPlayerFailedToPlay(self)
            } else if status == .ReadyToPlay {
                playbackState = .Playing
                thePlayer?.play()
            }
        }
    }
}

extension SPAudioPlayer {
    
    // MARK: - Private methods.
    func attachListener(playerItem: SPPlayerItem) {
        registerForTimeTracking(progressHandlerBlock)
        playerItem.addObserver(self, forKeyPath: "status", options: .New, context: nil)
    }
    
    func detachListener(playerItem: SPPlayerItem?) {
        unregisterTimeTracking()
        playerItem?.removeObserver(self, forKeyPath: "status")
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
