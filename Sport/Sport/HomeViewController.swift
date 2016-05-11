//
//  HomeViewController.swift
//  Sport
//
//  Created by Tien on 5/8/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var homePresenter: HomePresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homePresenter = HomePresenterImpl(view: self)
        
        homePresenter?.initialize()
    }
}

extension HomeViewController: HomeView {
    
}
