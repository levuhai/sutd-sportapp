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

class AudioPlayer: NSObject {
    
    enum AudioPlaybackState {
        case Stopped
        case Pause
        case Playing
    }
    
    // Shared instance.
    static let sharedInstance = AudioPlayer()
    
    // Instance variables
    var thePlayer: AVQueuePlayer?
    var playbackObserver: AnyObject?
    
    // Events handler.
    var progressHandlerBlock: ((progress: Double)->())?
    
    var playbackState: AudioPlaybackState = .Stopped

    func setup(playList: [String]) {
        
        let songQueue = createPlayerItems(playList)
        thePlayer = AVQueuePlayer(items: songQueue)
        thePlayer?.actionAtItemEnd = .Advance
    }
   
    // Test purpose only
    func setupTest(path: String) {
        let playerItem = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        thePlayer = AVQueuePlayer(playerItem: playerItem)
    }
    
    // MARK: - Event listeners
    // Set progress listener
    func setProgressHandler(block: (progress: Double)->()) {
        progressHandlerBlock = block
    }
    
    // MARK: - Playback functions
    func play() {
        attachListener()
        thePlayer?.play()
    }
    
    func pause() {
        thePlayer?.pause()
    }
    
    func stop() {
        detachListener()
        thePlayer?.pause()
    }
    
    func next() {
        
    }
    
}

extension AudioPlayer {
    
    // MARK: - Private methods.
    func attachListener() {
        registerForTimeTracking(progressHandlerBlock)
    }
    
    func detachListener() {
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