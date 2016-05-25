//
//  MusicViewController.swift
//  Sport
//
//  Created by Tien on 5/25/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songTempoLabel: UILabel!
    
    @IBOutlet weak var autoControlView: UIView!
    @IBOutlet weak var manualControlView: UIView!
    
    @IBOutlet weak var trackpadView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
