//
//  MusicViewController.swift
//  Sport
//
//  Created by Tien on 5/25/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decorate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func decorate() {
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
    
    func setButtonPlayImage(isPlaying: Bool) {
        if isPlaying {
            playPauseButton.setTitle(String.ioniconWithName(.IosPlay), forState: .Normal)
        } else {
            playPauseButton.setTitle(String.ioniconWithName(.IosPause), forState: .Normal)
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
}
