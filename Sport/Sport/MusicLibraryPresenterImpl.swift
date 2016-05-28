//
//  MusicLibraryPresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicLibraryPresenterImpl: NSObject, MusicLibraryPresenter {
    
    var libraryView: MusicLibraryView
    var songRepository: SongRepository
    var songImporter: SongImporter
    var songsList: [SongData] = []
    
    init(libraryView: MusicLibraryView, songRepository: SongRepository, songImporter: SongImporter) {
        self.libraryView = libraryView
        self.songRepository = songRepository
        self.songImporter = songImporter
    }
    
    func initialize() {
        
        libraryView.initViews()
        
        reloadData()
    }
    
    func reloadData() {
        let songList = songRepository.loadSongs()
        setSongs(songList)
        
        displaySongs()
    }
    
    func displaySongs() {
        if songsList.isEmpty {
            libraryView.showEmptyList()
        } else {
            libraryView.showSongList()
        }
    }
    
    func onError(error: NSError) {
        print("Error: \(error)")
    }
    
    func setSongs(songs: [SongData]?) {
        songsList.removeAll()
        
        if let realSongs = songs {
            songsList = realSongs
        }
    }
    
    func onBarButonReloadClick() {
        libraryView.showLoading(true)
        songImporter.importToRepository(self.songRepository) { 
            self.reloadData()
            
            self.libraryView.showLoading(false)
        }
    }
}

extension MusicLibraryPresenterImpl: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let songCell = tableView.dequeueReusableCellWithIdentifier("SongTableCell") as! SongTableCell
        let song = songsList[indexPath.row]
        songCell.displaySong(song)
        return songCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsList.count
    }
}

extension MusicLibraryPresenterImpl: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
}