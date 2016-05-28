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
    func showSongList()
    
    func showLoading(show: Bool)
    
    func enableRightBarButton(enable: Bool)
}
