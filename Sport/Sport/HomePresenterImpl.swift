//
//  HomePresenterImpl.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class HomePresenterImpl: HomePresenter {
    
    let view: HomeView!
    
    init(view: HomeView) {
        
        self.view = view
    }
    
    func initialize() {
        
        let lastTempo = AppUserDefaults.lastTempo()
        if let lastTempo = lastTempo {
            view.showCurrentTempoValue(lastTempo)
            view.updateTempoSliderValue(lastTempo)
        } else {
            view.showCurrentTempoValue(Constants.Defaults.tempoMin)
            view.updateTempoSliderValue(Constants.Defaults.tempoMin)
        }
    }
    
    func tempoValueChanged(newValue: Float) {
        view.showCurrentTempoValue(newValue)
    }
}
