//
//  HomePresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class HomePresenterImpl: HomePresenter {
    
    init(view: HomeView) {
        
    }
    
    func initialize() {
        ItunesDataImporter.importItunesSongs()
    }
}
