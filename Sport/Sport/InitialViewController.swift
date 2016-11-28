//
//  InitialViewController.swift
//  Sport
//
//  Created by Tien on 6/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class InitialViewController: UIViewController {

    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    
    let images = ["waiting_1", "waiting_2", "waiting_3"]
    var currentImageIndex = 0
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        print("Count: \(navigationController?.viewControllers.count)")
        // Do any additional setup after loading the view.
        let songSyncManager = ItunesSyncManager.sharedInstance
        let songRepository = SongRealmRepository.sharedInstance
        
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(changeBackgroundImage), userInfo: nil, repeats: true)
        
        songSyncManager.syncWithRepo(songRepository, progress: { [weak self] (current, total) in
            print("Processing \(current)/\(total)")
            let newValue = 100 * CGFloat(current) / CGFloat(total)
            let oldValue = self?.progressView.value ?? 0
            if newValue - oldValue > 10 {
                self?.progressView.value = newValue
            } else if newValue - oldValue > 0.5 {
                self?.progressView.value = newValue
            } else {
                self?.progressView.value = newValue
            }
            }, completion: {
                self.getStartedButton.isEnabled = true
                self.statusLabel.text = "All done"
                self.timer?.invalidate()
        })
    }

    func changeBackgroundImage() {
        currentImageIndex += 1
        if (currentImageIndex >= images.count) {
            currentImageIndex = 0
        }
        UIView.transition(with: slideImageView, duration: 1, options: .transitionCrossDissolve, animations: {
            self.slideImageView.image = UIImage(named: self.images[self.currentImageIndex])
            }, completion: nil)
    }
    
    @IBAction func getStartedButtonDidClick(_ sender: UIButton) {
        // Finished initializing
        AppUserDefaults.saveInitializeStatus(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let musicPlayerScreen = storyboard.instantiateViewController(withIdentifier: "MusicPlayerController")
        
        self.navigationController?.setViewControllers([musicPlayerScreen], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
