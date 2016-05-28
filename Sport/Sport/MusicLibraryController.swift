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
    
    @IBOutlet weak var songTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryPresenter = MusicLibraryPresenterImpl(libraryView: self, songRepository: SongRepositories.realmRepository, songImporter: BundleDataImporter.sharedInstance)
        songTableView.dataSource = libraryPresenter
        songTableView.delegate = libraryPresenter
        
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
        self.navigationController?.navigationBar.topItem!.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(40)] as Dictionary!
        
        // Add right bar button
        let rightBarButton =  UIBarButtonItem(title: String.ioniconWithName(.IosRefreshEmpty), style: .Plain, target: self, action: #selector(MusicLibraryController.barButtonReloadDidClick(_:)))
        rightBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        songTableView.rowHeight = UITableViewAutomaticDimension
        songTableView.estimatedRowHeight = 10
    }
    
    func showEmptyList() {
        // emptyView.hidden = false
        songTableView.hidden = true
    }
    
    func showSongList() {
        songTableView.hidden = false
        // emptyView.hidden = true
        songTableView.reloadData()
    }
    
    func barButtonReloadDidClick(sender: UIBarButtonItem) {
        libraryPresenter?.onBarButonReloadClick()
    }
    
    func showLoading(show: Bool) {
        if (show) {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        } else {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    func enableRightBarButton(enable: Bool) {
        self.navigationItem.rightBarButtonItem?.enabled = enable
    }
}