//
//  MusicPlayerPresenter.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol MusicPlayerPresenter: class {
    
    var playerView: MusicPlayerView? { get }
    
    func initialize()
    
    func onLeftBarButtonClicked()
    
    func onRightBarButtonClicked()
    
    func onPlayPauseButonClicked()
    func onRewindButtonClicked()
    func onFastForwardButtonClicked()
}
