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

    let playlistHeaderViewHeight: CGFloat = 44
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var autoControlView: UIView!
    @IBOutlet weak var manualControlView: UIView!
    
    @IBOutlet weak var trackpadView: UIView!
    
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    @IBOutlet weak var tnTempoSlider: TNSlider!
//    @IBOutlet weak var tempoSlider: SPSlider!
    @IBOutlet weak var playlistView: UIView!
    @IBOutlet weak var playlistHeaderView: UIView!
    @IBOutlet weak var expandCollapseButton: UIButton!
    
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var playlistSummaryLabel: UILabel!
    
    @IBOutlet weak var topPlaylistToParentBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomPlaylistToParentBottomConstraint: NSLayoutConstraint!
    
    
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
        screenPresenter = MusicPlayerPresenterImpl(musicView: self, router: router, songRepository: SongRealmRepository.sharedInstance)
        
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
    
    @IBAction func tempoSliderValueChanged(sender: TNSlider) {
        screenPresenter?.onTempoSliderValueChanged(sender.value)
    }
    
    @IBAction func playlistButtonDidClick(sender: UIButton) {
        toggleShowPlaylist()
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
    
    func controlButtonLongPressed(gesture: UILongPressGestureRecognizer) {
        let sender = gesture.view
        let state = gesture.state
        
        switch state {
        case .Began:
            if sender == rewindButton {
                screenPresenter?.onRewindStarted()
            } else if sender == fastForwardButton {
                screenPresenter?.onFastForwardStarted()
            }
        case .Ended:
            if sender == rewindButton {
                screenPresenter?.onRewindEnded()
            } else if sender == fastForwardButton {
                screenPresenter?.onFastForwardEnded()
            }
        default:
            break
        }
    }
    
    func toggleShowPlaylist() {
        showPlaylistView(!isPlaylistOpened, animated: true)
        isPlaylistOpened = !isPlaylistOpened
    }
}

extension MusicPlayerController: MusicPlayerView {
    func initialize() {
        self.title = "Music"
        
        tnTempoSlider.minimumValue = 20
        tnTempoSlider.maximumValue = 200
        
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
        playlistTableView.rowHeight = UITableViewAutomaticDimension
        playlistTableView.estimatedRowHeight = 80
        
        let tapPlaylistHeaderGesture = UITapGestureRecognizer(target: self, action: #selector(MusicPlayerController.toggleShowPlaylist))
        playlistHeaderView.addGestureRecognizer(tapPlaylistHeaderGesture)
        
        // Navigation bar items
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "music_library")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(MusicPlayerController.leftBarButtonDidClick(_:)))
        leftBarItem.tintColor = UIColor.blueColor()
        
        self.navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "ic_running")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(MusicPlayerController.rightBarButtonDidClick(_:)))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        // Setting font then icon for title
        playPauseButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        playPauseButton.layer.cornerRadius = playPauseButton.frame.size.width / 2
        setButtonPlayImage(true)
        
        rewindButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        rewindButton.setTitle(String.ioniconWithName(.IosRewind), forState: .Normal)
        
        fastForwardButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        fastForwardButton.setTitle(String.ioniconWithName(.IosFastforward), forState: .Normal)
        
        expandCollapseButton.titleLabel?.font = UIFont.ioniconOfSize(24)
        expandCollapseButton.setTitle(String.ioniconWithName(.ArrowUpB), forState: .Normal)
        
        let longTapFastForwardGestureRegcognizer = UILongPressGestureRecognizer(target: self, action: #selector(MusicPlayerController.controlButtonLongPressed(_:)))
        fastForwardButton.addGestureRecognizer(longTapFastForwardGestureRegcognizer)
        
        let longTapRewindGestureRegcognizer = UILongPressGestureRecognizer(target: self, action: #selector(MusicPlayerController.controlButtonLongPressed(_:)))
        rewindButton.addGestureRecognizer(longTapRewindGestureRegcognizer)
        
        updatePlaybackProgress(0)
        
        showPlaylistView(false, animated: false)
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
//        tempoSlider.setValue(tempo, animated: true)
        tnTempoSlider.value = tempo
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
        playlistSummaryLabel.text = "Total \(playlist.count) \(playlist.count > 1 ? "songs" : "song")"
        playlistTableView.reloadData()
    }
    
    func showPlaylistView(show: Bool, animated: Bool) {
        var expandButtonIcon: String
        if show {
            expandButtonIcon = String.ioniconWithName(.ArrowDownB)
            topPlaylistToParentBottomConstraint.constant = self.view.bounds.size.height
            bottomPlaylistToParentBottomConstraint.constant = 0
        } else {
            expandButtonIcon = String.ioniconWithName(.ArrowUpB)
            bottomPlaylistToParentBottomConstraint.constant = -100
            topPlaylistToParentBottomConstraint.constant = playlistHeaderViewHeight
        }
        self.view.setNeedsLayout()
        if animated {
            UIView.animateWithDuration(0.5, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (success) in
                    self.expandCollapseButton.setTitle(expandButtonIcon, forState: .Normal)
            })
        } else {
            self.view.layoutIfNeeded()
            self.expandCollapseButton.setTitle(expandButtonIcon, forState: .Normal)
        }
    }
    
    func showPlayingSongInPlaylist(indexInPlaylist: Int) {
        // Change status of songViewData(s), determine which song is currently playing
        for i in 0..<playlistSong.count {
            let songAtIndex = playlistSong[i]
            if i == indexInPlaylist {
                songAtIndex.isPlaying = true
            } else {
                songAtIndex.isPlaying = false
            }
        }
        playlistTableView.reloadData()
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension MusicPlayerController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        screenPresenter?.playlistDidSelectItemAtIndex(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
