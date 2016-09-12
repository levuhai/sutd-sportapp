//
//  MusicLibraryPresenter.swift
//  Sport
//
//  Created by Tien on 5/27/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol MusicLibraryPresenter: class {
    var libraryView: MusicLibraryView? { get }
    
    func initialize()
    
    func onBarButonReloadClick()
}
