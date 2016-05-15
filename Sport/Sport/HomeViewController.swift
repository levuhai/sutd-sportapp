//
//  HomeViewController.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var currentTempoLabel: UILabel!
    
    var homePresenter: HomePresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homePresenter = HomePresenterImpl(view: self)
        
        homePresenter?.initialize()
    }
    
    @IBAction func tempoSliderValueChanged(sender: UISlider) {
        homePresenter?.tempoValueChanged(sender.value)
    }
}

extension HomeViewController: HomeView {
    func showCurrentTempoValue(tempoValue: Float) {
        currentTempoLabel.text = "\(Int(tempoValue))"
    }
    
    func updateTempoSliderValue(tempoValue: Float) {
        tempoSlider.setValue(tempoValue, animated: true)
    }
}
