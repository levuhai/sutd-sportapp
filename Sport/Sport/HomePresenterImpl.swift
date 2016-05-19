//
//  HomePresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class HomePresenterImpl: HomePresenter {
    
    weak var view: HomeView?
    let songRepository: SongRepository!
    
    init(view: HomeView, repository: SongRepository) {
        
        self.view = view
        self.songRepository = repository
    }
    
    func initialize() {
        
        let lastTempo = AppUserDefaults.lastTempo()
        if let lastTempo = lastTempo {
            view?.showCurrentTempoValue(lastTempo)
            view?.updateTempoSliderValue(lastTempo)
        } else {
            view?.showCurrentTempoValue(Constants.Defaults.tempoMin)
            view?.updateTempoSliderValue(Constants.Defaults.tempoMin)
        }
        
        songRepository.importSongsWithCompletion { 
            print("Presenter -- Import completed")
        }
    }
    
    func tempoValueChanged(newValue: Float) {
        view?.showCurrentTempoValue(newValue)
    }
}
