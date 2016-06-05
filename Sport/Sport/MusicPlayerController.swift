//
//  MusicPlayerController.swift
//  Sport
//
//  Created by Tien on 5/25/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class MusicPlayerController: UIViewController {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var autoControlView: UIView!
    @IBOutlet weak var manualControlView: UIView!
    
    @IBOutlet weak var trackpadView: UIView!
    
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    @IBOutlet weak var tempoSlider: SPSlider!
    @IBOutlet weak var playlistView: UIView!
    @IBOutlet weak var playlistHeaderView: UIView!
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBOutlet weak var topPlaylistToParentBottomConstraint: NSLayoutConstraint!
    
    
    var currentSong: SongData?
    var playlistSong = [SongViewData]()
    
    var screenPresenter: MusicPlayerPresenter?
    var isPlaylistOpened = false
    
    
    deinit {
        print("MusicVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let router = MusicPlayerRouterImpl(controller: self)
        screenPresenter = MusicPlayerPresenterImpl(musicView: self, router: router, songRepository: SongRepositories.realmRepository)
        
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
    
    @IBAction func tempoSliderValueChanged(sender: UISlider) {
        print("Tempo value: \(sender.value)")
        screenPresenter?.onTempoSliderValueChanged(sender.value)
    }
    
    @IBAction func playlistButtonDidClick(sender: UIButton) {
        showPlaylistView(!isPlaylistOpened, animated: true)
        isPlaylistOpened = !isPlaylistOpened
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskPlaylistView()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if isPlaylistOpened {
            topPlaylistToParentBottomConstraint.constant = self.view.bounds.size.height
        }
        maskPlaylistView()
        self.view.layoutIfNeeded()
    }
    
    func maskPlaylistView() {
        let maskPath = UIBezierPath(roundedRect: playlistHeaderView.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(10, 10))
        let mask = CAShapeLayer()
        mask.path = maskPath.CGPath
        playlistHeaderView.layer.mask = mask
        playlistHeaderView.clipsToBounds = true
    }
}

extension MusicPlayerController: MusicPlayerView {
    func initialize() {
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
        playlistTableView.rowHeight = UITableViewAutomaticDimension
        playlistTableView.estimatedRowHeight = 80
        
        let leftBarItem = UIBarButtonItem(title: "LIB", style: .Plain, target: self, action: #selector(MusicPlayerController.leftBarButtonDidClick(_:)))
        self.navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(title: "M", style: .Plain, target: self, action: #selector(MusicPlayerController.rightBarButtonDidClick(_:)))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        updatePlaybackProgress(0)
        
        decorate()
        
        showPlaylistView(false, animated: false)
        
        displayPlaylist(DependencyInjector.dummyPlaylistToView())
    }
    
    func switchControlMode(runningMode: Bool) {
        if runningMode {
            showAutoControl()
        } else {
            showManualControl()
        }
    }
    
    func updatePlaybackProgress(progress: Double) {
        progressView.value = CGFloat(progress)
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
        setButtonPlayImage(true)
        
        rewindButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        rewindButton.setTitle(String.ioniconWithName(.IosRewind), forState: .Normal)
        
        fastForwardButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        fastForwardButton.setTitle(String.ioniconWithName(.IosFastforward), forState: .Normal)
        
        
    }
    
    private func setButtonPlayImage(isPlaying: Bool) {
        if isPlaying {
            playPauseButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            playPauseButton.setTitle(String.ioniconWithName(.IosPause), forState: .Normal)
        } else {
            playPauseButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            playPauseButton.setTitle(String.ioniconWithName(.IosPlay), forState: .Normal)
        }
    }
    
    func setTempoSliderValue(tempo: Float) {
        tempoSlider.setValue(tempo, animated: true)
    }
    
    func updateViewForPlayingState(isPlaying: Bool) {
        setButtonPlayImage(isPlaying)
    }
    
    func updateSongInfo(playerViewData: SongViewData) {
        songTitleLabel.text = playerViewData.title
        albumImageView.image = playerViewData.image
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func displayPlaylist(playlist: [SongViewData]) {
        self.playlistSong = playlist
        playlistTableView.reloadData()
    }
    
    func showPlaylistView(show: Bool, animated: Bool) {
        if show {
            topPlaylistToParentBottomConstraint.constant = self.view.bounds.size.height
        } else {
            topPlaylistToParentBottomConstraint.constant = 44
        }
        self.view.setNeedsLayout()
        if animated {
            UIView.animateWithDuration(0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension MusicPlayerController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistSongCell") as! PlaylistSongCell
        let songInfo = playlistSong[indexPath.row]
        cell.displaySongInfo(songInfo.title, album: songInfo.artist, image: songInfo.image, playing: songInfo.isPlaying)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistSong.count
    }
}

extension MusicPlayerController: UITableViewDelegate {
    
}
