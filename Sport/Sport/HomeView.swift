//
//  HomeView.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

protocol HomeView: class {
    func showCurrentTempoValue(tempoValue: Float)
    func updateTempoSliderValue(tempoValue: Float)
}
