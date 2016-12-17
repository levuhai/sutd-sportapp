//
//  MusicLibraryController.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import MBProgressHUD

class MusicLibraryController: UIViewController {
    
    var libraryPresenter: MusicLibraryPresenter?
    var songViewData = [SongViewData]()
    var hud: MBProgressHUD?
    
    @IBOutlet weak var songTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTableView.dataSource = self
        songTableView.delegate = self
        
        libraryPresenter = MusicLibraryPresenterImpl(libraryView: self, songRepository: SongRealmRepository.sharedInstance, songSyncManager: ItunesSyncManager.sharedInstance)
        
        libraryPresenter?.initialize()
    }
}

extension MusicLibraryController: MusicLibraryView {
    
    func initViews() {
        self.title = "Library"
        
        // Remve title of back button
        // Notes ***
        // Top item of navigation bar is navigation item of parent view controller. Here we have two view controllers so viewControllers[0] is parent of this view controller.
        // print(self.navigationController?.navigationBar.topItem == self.navigationController?.viewControllers[0].navigationItem)
        // So, if we want to custom back button shown in this vc, you should do like this.
        self.navigationController?.navigationBar.topItem!.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //create a new button
        let button: UIButton = UIButton.init(type:.custom)
        //set image for button
        button.setImage(#imageLiteral(resourceName: "Restart_fafafa_100"), for:.normal)
        //add function for button
        button.addTarget(self, action: #selector(MusicLibraryController.barButtonReloadDidClick(_:)), for: .touchUpInside)
        //set frame
        button.frame = CGRect.init(x:0, y:0, width:32, height:32)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        
        songTableView.rowHeight = UITableViewAutomaticDimension
        songTableView.estimatedRowHeight = 10
    }
    
    func showEmptyList() {
        // emptyView.hidden = false
        songTableView.isHidden = true
    }
    
    func showSongList(_ songViewData: [SongViewData]) {
        self.songViewData = songViewData
        songTableView.isHidden = false
        // emptyView.hidden = true
        songTableView.reloadData()
    }
    
    func barButtonReloadDidClick(_ sender: UIBarButtonItem) {
        libraryPresenter?.onBarButonReloadClick()
    }
    
    func showLoading(_ show: Bool) {
        if (show) {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func dispatchProgress(_ completed: Int, total: Int) {
        hud?.label.text = "Processing \(completed)/\(total)"
    }
    
    func enableRightBarButton(_ enable: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = enable
    }
}

extension MusicLibraryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongTableCell") as! SongTableCell
        let song = songViewData[(indexPath as NSIndexPath).row]
        songCell.displaySong(song)
        return songCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songViewData.count
    }
}

extension MusicLibraryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
