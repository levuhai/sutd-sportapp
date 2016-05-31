//
//  AudioPlayer.swift
//  Sport
//
//  Created by Tien on 5/30/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

enum AudioPlaybackState {
    case Stopped
    case Paused
    case Playing
}

class AudioPlayer: NSObject {
    
    
    
    // Shared instance.
    static let sharedInstance = AudioPlayer()
    
    // Instance variables
    var thePlayer: AVPlayer?
    var playbackObserver: AnyObject?
    
    var playerItems: [AVPlayerItem] = []
    var currentPlayingIndex = 0
    var currentItem: AVPlayerItem? {
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AudioPlayer.playerItemDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: currentItem)
        }
    }
    // Events handler.
    var progressHandlerBlock: ((progress: Double)->())?
    
    var playbackState: AudioPlaybackState = .Stopped

    func setup(playList: [String]) {
        
        let songQueue = createPlayerItems(playList)
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
        if (currentItem == nil) {
            return
        }
        
        thePlayer = AVPlayer(playerItem: currentItem!)
        attachListener(currentItem!)
        
        playbackState = .Playing
        thePlayer?.play()
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
        detachListener(currentItem!)
        thePlayer?.pause()
    }
    
    func playNext() {
        stop()
        if let nextItem = nextPlayerItem() {
            currentPlayingIndex += 1
            currentItem = nextItem
            play()
        } else {
            didStoppedPlaying()
        }
    }
    
    func playPrevious() {
        stop()
        if let previousItem = previousPlayerItem() {
            currentPlayingIndex -= 1
            currentItem = previousItem
            play()
        } else {
            didStoppedPlaying()
        }
    }
    
    func isPlaying() -> Bool {
        return playbackState == .Playing
    }
    
    func nextPlayerItem() -> AVPlayerItem? {
        if (currentPlayingIndex + 1 == playerItems.count) {
            return nil
        }
        return playerItems[currentPlayingIndex + 1]
    }
    
    func previousPlayerItem() -> AVPlayerItem? {
        if (currentPlayingIndex == 0) {
            return nil
        }
        return playerItems[currentPlayingIndex - 1]
    }
    
    func playerItemDidFinishPlaying(notification: NSNotification) {
        playNext()
    }
    
    func didStartedPlaySong(song: AVPlayerItem) {
        
    }
    
    func didStoppedPlaying() {
        
    }
}

extension AudioPlayer {
    
    // MARK: - Private methods.
    func attachListener(playerItem: AVPlayerItem) {
        registerForTimeTracking(progressHandlerBlock)
    }
    
    func detachListener(playerItem: AVPlayerItem) {
        unregisterTimeTracking()
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

extension AudioPlayer {
    // Create list of playerItems from list of song's persistent ids.
    private func createPlayerItems(songPersistentIds: [String]) -> [AVPlayerItem] {
        var playerItems: [AVPlayerItem] = []
        for persistentId in songPersistentIds {
            // make sure the song with that id is currently exist.
            let mediaItem = MPMediaItemFromPersistentId(persistentId)
            if mediaItem == nil {
                continue
            }
            // Make sure that media item is local file (has avassetURL)
            let avasset = AVAssetFromMPMediaItem(mediaItem!)
            if avasset == nil {
                continue
            }
            
            let playerItem = AVPlayerItem(asset: avasset!)
            playerItems.append(playerItem)
        }
        return playerItems
    }
    
    private func AVAssetFromMPMediaItem(mediaItem: MPMediaItem) -> AVAsset? {
        guard let assetURL = mediaItem.assetURL else {
            return nil
        }
        return AVURLAsset(URL: assetURL)
    }
    
    // Get media item from persistentId.
    private func MPMediaItemFromPersistentId(persistentId: String) -> MPMediaItem? {
        let query = MPMediaQuery.songsQuery()
        let predicate = MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyPersistentID)
        query.addFilterPredicate(predicate)
        return query.items?.first
    }
}