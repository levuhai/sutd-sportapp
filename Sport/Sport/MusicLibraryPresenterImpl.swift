//
//  MusicLibraryPresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicLibraryPresenterImpl: NSObject, MusicLibraryPresenter {
    
    weak var libraryView: MusicLibraryView?
    
    var songRepository: SongRepository
    var songSyncManager: SongSyncManager
    var songsList = [SongViewData]()
    
    init(libraryView: MusicLibraryView, songRepository: SongRepository, songSyncManager: SongSyncManager) {
        self.libraryView = libraryView
        self.songRepository = songRepository
        self.songSyncManager = songSyncManager
    }
    
    func initialize() {
        
        libraryView?.initViews()
        
        
        reloadData()
    }
    
    func reloadData() {
        songsList = songRepository.loadListSongViewData()
        
        displaySongs()
    }
    
    func displaySongs() {
        if songsList.isEmpty {
            libraryView?.showEmptyList()
        } else {
            libraryView?.showSongList(songsList)
        }
    }
    
    func onError(error: NSError) {
        print("Error: \(error)")
    }
    
    func onBarButonReloadClick() {
        libraryView?.enableRightBarButton(false)
        libraryView?.showLoading(true)
        songSyncManager.syncWithRepo(songRepository, completion: { 
            self.reloadData()
            
            self.libraryView?.enableRightBarButton(true)
            self.libraryView?.showLoading(false)
        })
    }
}

