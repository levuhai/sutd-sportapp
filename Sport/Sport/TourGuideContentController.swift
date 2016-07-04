//
//  TourGuideContentController.swift
//  Sport
//
//  Created by Tien on 6/28/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class TourGuideContentController: UIViewController {

    var pageTitle = ""
    var guideImageName = ""
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var guideImageView: UIImageView!
    
    var pageIndex = 0
    var enableFinishButton = false
    var finishAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = pageTitle
        guideImageView.clipsToBounds = true
        guideImageView.image = UIImage(named: guideImageName)
        
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor.sportPink().CGColor
        actionButton.layer.cornerRadius = 8
        actionButton.hidden = !enableFinishButton
        
        view.bringSubviewToFront(titleLabel)
        view.bringSubviewToFront(actionButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableFinishButtonWithAction(action: ()->Void) {
        enableFinishButton = true
        finishAction = action
    }
    
    @IBAction func buttonFinishDidClick(sender: UIButton) {
        finishAction?()
    }
    
}
