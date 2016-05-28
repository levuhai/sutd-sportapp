//
//  MusicPlayerController.swift
//  Sport
//
//  Created by Tien on 5/25/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicPlayerController: UIViewController {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songTempoLabel: UILabel!
    
    @IBOutlet weak var autoControlView: UIView!
    @IBOutlet weak var manualControlView: UIView!
    
    @IBOutlet weak var trackpadView: UIView!
    
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    
    var currentSong: SongData?
    var screenPresenter: MusicPlayerPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let router = MusicPlayerRouterImpl(controller: self)
        screenPresenter = MusicPlayerPresenterImpl(musicView: self, router: router)
        
        screenPresenter?.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftBarButtonDidClick(sender: UIBarButtonItem) {
        screenPresenter?.onLeftBarButtonClicked()
    }
    
    func rightBarButtonDidClick(sender: UIBarButtonItem) {
        screenPresenter?.onRightBarButtonClicked()
    }
    
    @IBAction func playpauseButtonDidClick(sender: UIButton) {
        screenPresenter?.onPlayPauseButonClicked()
    }
    
    @IBAction func fastforwardButtonDidClick(sender: UIButton) {
        screenPresenter?.onFastForwardButtonClicked()
    }
    
    @IBAction func rewindButtonDidClick(sender: UIButton) {
        screenPresenter?.onRewindButtonClicked()
    }
}

extension MusicPlayerController: MusicPlayerView {
    func initialize() {
        let leftBarItem = UIBarButtonItem(title: "LIB", style: .Plain, target: self, action: #selector(MusicPlayerController.leftBarButtonDidClick(_:)))
        self.navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(title: "M", style: .Plain, target: self, action: #selector(MusicPlayerController.rightBarButtonDidClick(_:)))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        decorate()
    }
    
    func switchControlMode(runningMode: Bool) {
        if runningMode {
            showAutoControl()
        } else {
            showManualControl()
        }
    }
    
    func showManualControl() {
        autoControlView.hidden = true
        manualControlView.hidden = false
    }
    
    func showAutoControl() {
        manualControlView.hidden = true
        autoControlView.hidden = false
    }
    
    // MARK -- Private methods
    private func decorate() {
        // Setting font then icon for title
        playPauseButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        playPauseButton.layer.cornerRadius = playPauseButton.frame.size.width / 2
        playPauseButton.layer.borderColor = UIColor.sportPink().CGColor
        playPauseButton.layer.borderWidth = 1.5
        setButtonPlayImage(true)
        
        rewindButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        rewindButton.setTitle(String.ioniconWithName(.IosRewind), forState: .Normal)
        
        fastForwardButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        fastForwardButton.setTitle(String.ioniconWithName(.IosFastforward), forState: .Normal)
    }
    
    private func setButtonPlayImage(isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setTitle(String.ioniconWithName(.IosPlay), forState: .Normal)
        } else {
            playPauseButton.setTitle(String.ioniconWithName(.IosPause), forState: .Normal)
        }
    }
    
    
}
