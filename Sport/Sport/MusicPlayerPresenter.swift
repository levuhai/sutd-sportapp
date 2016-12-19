//
//  MusicPlayerPresenter.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol MusicPlayerPresenter: SPActivityRateViewDataSource {
    
    var playerView: MusicPlayerView? { get }
    
    func initialize()
    
    func onLeftBarButtonClicked()
    
    func onRightBarButtonClicked()
    
    func onPlayPauseButonClicked()
    func onRewindButtonClicked()
    func onFastForwardButtonClicked()
    func onFastForwardStarted()
    func onFastForwardEnded()
    func onRewindStarted()
    func onRewindEnded()
    
    func onTempoSliderValueChanged(_ newValue: Float)
    func onTrackPadValueChanged(_ eValue: Float, _ vValue: Float)
    
    func playlistDidSelectItemAtIndex(_ indexPath: IndexPath)
}
