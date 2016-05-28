//
//  MusicPlayerRouterImpl.swift
//  Sport
//
//  Created by Tien on 5/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicPlayerRouterImpl: NSObject, MusicPlayerRouter {
    
    weak var controller: MusicPlayerController!
    
    init(controller: MusicPlayerController) {
        self.controller = controller
    }
    
    func navigateToLibraryScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let libraryVc = sb.instantiateViewControllerWithIdentifier("MusicLibraryController")
        self.controller.navigationController?.pushViewController(libraryVc, animated: true)
    }
    
    deinit {
        print("MusicPlayerRouterImpl deinit")
    }
}
