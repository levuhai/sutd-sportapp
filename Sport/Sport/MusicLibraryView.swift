//
//  MusicLibraryView.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol MusicLibraryView: class {
    func initViews()
    
    func showEmptyList()
    func showSongList(_ songViewData: [SongViewData])
    
    func showLoading(_ show: Bool)
    func dispatchProgress(_ completed: Int, total: Int)
    
    func enableRightBarButton(_ enable: Bool)
}
