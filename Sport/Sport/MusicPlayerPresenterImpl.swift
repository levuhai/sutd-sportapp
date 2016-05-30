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
    var runningMode = false
    
    init(musicView: MusicPlayerView, router: MusicPlayerRouter) {
        self.playerView = musicView
        self.router = router
        
        super.init()
    }
    
    func initialize() {
        playerView?.initialize()
        
        let audioPlayer = AudioPlayer.sharedInstance
        audioPlayer.setup(["1339496926179059070"])
        audioPlayer.setProgressHandler { [unowned self] (progress) in
            self.playerView?.updatePlaybackProgress(progress)
        }
        audioPlayer.attachListener()
        audioPlayer.play()
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
        
    }
}

