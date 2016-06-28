//
//  InitialViewController.swift
//  Sport
//
//  Created by Tien on 6/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        print("Count: \(navigationController?.viewControllers.count)")
        // Do any additional setup after loading the view.
        let songSyncManager = ItunesSyncManager.sharedInstance
        let songRepository = SongRealmRepository.sharedInstance
        
        songSyncManager.syncWithRepo(songRepository, progress: { (current, total) in
            print("Processing \(current)/\(total)")
            }, completion: {
                self.getStartedButton.enabled = true
        })
    }

    @IBAction func getStartedButtonDidClick(sender: UIButton) {
        // Finished initializing
        AppUserDefaults.saveInitializeStatus(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let musicPlayerScreen = storyboard.instantiateViewControllerWithIdentifier("MusicPlayerController")
        
        self.navigationController?.setViewControllers([musicPlayerScreen], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
