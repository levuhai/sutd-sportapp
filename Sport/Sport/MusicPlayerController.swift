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
    
    @IBOutlet weak var trackpadView: SPTrackPad!
    @IBOutlet weak var activityRateView: SPActivityRateView!
    @IBOutlet weak var stepCountLabel: UILabel!
    
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    @IBOutlet weak var tnTempoSlider: TNSlider!

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
    
    func leftBarButtonDidClick(_ sender: UIBarButtonItem) {
        screenPresenter?.onLeftBarButtonClicked()
    }
    
    func rightBarButtonDidClick(_ sender: UIBarButtonItem) {
        screenPresenter?.onRightBarButtonClicked()
    }
    
    @IBAction func playpauseButtonDidClick(_ sender: UIButton) {
        screenPresenter?.onPlayPauseButonClicked()
    }
    
    @IBAction func fastforwardButtonDidClick(_ sender: UIButton) {
        screenPresenter?.onFastForwardButtonClicked()
    }
    
    @IBAction func rewindButtonDidClick(_ sender: UIButton) {
        screenPresenter?.onRewindButtonClicked()
    }
    
    @IBAction func tempoSliderValueChanged(_ sender: TNSlider) {
        screenPresenter?.onTempoSliderValueChanged(sender.value)
    }
    
    @IBAction func playlistButtonDidClick(_ sender: UIButton) {
        toggleShowPlaylist()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskPlaylistView()
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if isPlaylistOpened {
            topPlaylistToParentBottomConstraint.constant = self.view.bounds.size.height
        }
        maskPlaylistView()
        self.view.layoutIfNeeded()
    }
    
    func maskPlaylistView() {
        let maskPath = UIBezierPath(roundedRect: playlistHeaderView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = maskPath.cgPath
        playlistHeaderView.layer.mask = mask
        playlistHeaderView.clipsToBounds = true
    }
    
    func controlButtonLongPressed(_ gesture: UILongPressGestureRecognizer) {
        let sender = gesture.view
        let state = gesture.state
        
        switch state {
        case .began:
            if sender == rewindButton {
                screenPresenter?.onRewindStarted()
            } else if sender == fastForwardButton {
                screenPresenter?.onFastForwardStarted()
            }
        case .ended:
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
        
        // Setup trackpad view.
        trackpadView.layer.cornerRadius = 8
        trackpadView.clipsToBounds = true
        
        // Setup activity rate view
        activityRateView.layer.cornerRadius = 8
        activityRateView.clipsToBounds = true
        
        // ==============================================================
        // Setup playlist view
        initPlaylistView()
        
        // ==============================================================
        // Navigation bar items
        initNavigationBar()
        
        // ==============================================================
        // Setup music control
        initMusicControlView()
        
        activityRateView.dataSource = screenPresenter
    }
    
    func initPlaylistView() {
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
        playlistTableView.rowHeight = UITableViewAutomaticDimension
        playlistTableView.estimatedRowHeight = 80
        
        let tapPlaylistHeaderGesture = UITapGestureRecognizer(target: self, action: #selector(MusicPlayerController.toggleShowPlaylist))
        playlistHeaderView.addGestureRecognizer(tapPlaylistHeaderGesture)
        
        expandCollapseButton.titleLabel?.font = UIFont.ioniconOfSize(24)
        expandCollapseButton.setTitle(String.ioniconWithName(.ArrowUpB), for: UIControlState())
        
        // Playing song info.
        updateSongInfo(nil)
        
        showPlaylistView(false, animated: false)
    }
    
    func initNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "Playlist")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(MusicPlayerController.leftBarButtonDidClick(_:)))
        leftBarItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "Trainers")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(MusicPlayerController.rightBarButtonDidClick(_:)))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func initMusicControlView() {
        playPauseButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        playPauseButton.layer.cornerRadius = playPauseButton.frame.size.width / 2
        setButtonPlayImage(true)
        
        rewindButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        rewindButton.setTitle(String.ioniconWithName(.IosRewind), for: UIControlState())
        
        fastForwardButton.titleLabel?.font = UIFont.ioniconOfSize(45)
        fastForwardButton.setTitle(String.ioniconWithName(.IosFastforward), for: UIControlState())
        
        let longTapFastForwardGestureRegcognizer = UILongPressGestureRecognizer(target: self, action: #selector(MusicPlayerController.controlButtonLongPressed(_:)))
        fastForwardButton.addGestureRecognizer(longTapFastForwardGestureRegcognizer)
        
        let longTapRewindGestureRegcognizer = UILongPressGestureRecognizer(target: self, action: #selector(MusicPlayerController.controlButtonLongPressed(_:)))
        rewindButton.addGestureRecognizer(longTapRewindGestureRegcognizer)
        
        // Init
        updatePlaybackProgress(0)
    }
    
    func switchControlMode(_ runningMode: Bool) {
        if runningMode {
            showAutoControl()
        } else {
            showManualControl()
        }
    }
    
    func updatePlaybackProgress(_ progress: Double) {
        progressView.value = CGFloat(progress)
    }
    
    func showManualControl() {
        autoControlView.isHidden = true
        manualControlView.isHidden = false
        
        activityRateView.stopReceivingUpdates()
    }
    
    func showAutoControl() {
        activityRateView.startReceivingUpdate()
        
        manualControlView.isHidden = true
        autoControlView.isHidden = false
    }
    
    // MARK -- Private methods
    
    fileprivate func setButtonPlayImage(_ isPlaying: Bool) {
        if isPlaying {
            playPauseButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            playPauseButton.setTitle(String.ioniconWithName(.IosPause), for: UIControlState())
        } else {
            playPauseButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            playPauseButton.setTitle(String.ioniconWithName(.IosPlay), for: UIControlState())
        }
    }
    
    func setTempoSliderValue(_ tempo: Float) {
//        tempoSlider.setValue(tempo, animated: true)
        tnTempoSlider.value = tempo
    }
    
    func updateViewForPlayingState(_ isPlaying: Bool) {
        setButtonPlayImage(isPlaying)
    }
    
    func updateSongInfo(_ playerViewData: SongViewData?) {
        if (playerViewData == nil) {
            songTitleLabel.text = "---"
            albumImageView.image = UIImage(named: "unknown_album")
        } else {
            songTitleLabel.text = playerViewData!.title
            albumImageView.image = playerViewData!.image
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func displayPlaylist(_ playlist: [SongViewData]) {
        self.playlistSong = playlist
        playlistSummaryLabel.text = "Total \(playlist.count) \(playlist.count > 1 ? "songs" : "song")"
        playlistTableView.reloadData()
    }
    
    func showPlaylistView(_ show: Bool, animated: Bool) {
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
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                }, completion: { (success) in
                    self.expandCollapseButton.setTitle(expandButtonIcon, for: UIControlState())
            })
        } else {
            self.view.layoutIfNeeded()
            self.expandCollapseButton.setTitle(expandButtonIcon, for: UIControlState())
        }
    }
    
    func showPlayingSongInPlaylist(_ indexInPlaylist: Int) {
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
    
    func updateActivityRatesData(_ data: Float) {
        activityRateView.add(data)
    }
    
    func updateStepCount(_ stepCount: Int) {
        stepCountLabel.text = "\(stepCount)"
    }
}

extension MusicPlayerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistSongCell") as! PlaylistSongCell
        let songInfo = playlistSong[(indexPath as NSIndexPath).row]
        cell.displaySongInfo(songInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistSong.count
    }
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension MusicPlayerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        screenPresenter?.playlistDidSelectItemAtIndex(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
