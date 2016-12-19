//
//  SPTrackPad.swift
//  Sport
//
//  Created by Tien on 6/12/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SPTrackPad: UIControl {
    
    let ENERGY_MAX: Float = Constants.Defaults.energyMax
    let ENERGY_MIN: Float = Constants.Defaults.energyMin
    
    let VALENCE_MAX: Float = Constants.Defaults.valenceMax
    let VALENCE_MIN: Float = Constants.Defaults.valenceMin
    
   
    
    // TODO:
    var previousPosition: CGPoint = CGPoint(x: 1, y: 1)
    
    var valence: Float = 0
    var energy: Float = 0.5
    
    var dot: UIImageView!
    
    override func awakeFromNib() {
        
        dot = UIImageView.init(image: #imageLiteral(resourceName: "dot"))
        self.addSubview(dot)
        
        
        valence = VALENCE_MIN
        energy = ENERGY_MAX
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        setDotPosition(touchPoint)
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        setDotPosition(touchPoint)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        print("End tracking")
        sendActions(for: .valueChanged)
    }
    
    func setValue(_ e: Float, _ v: Float) {
        self.energy = e
        self.valence = v
        
        let posY = (e-ENERGY_MIN)/(ENERGY_MAX-ENERGY_MIN)*Float(self.height())
        let posX = (v-VALENCE_MIN)/(VALENCE_MAX-VALENCE_MIN)*Float(self.width())
        dot.setCenter(newCenter: CGPoint(x: CGFloat(posX), y: CGFloat(posY)))
    }
    
    func setDotPosition(_ p: CGPoint) {
        previousPosition = p
        dot.setCenter(newCenter: p)
        
        energy = (ENERGY_MAX-ENERGY_MIN)*(Float(p.y/self.height()))+ENERGY_MIN
        valence = (VALENCE_MAX-VALENCE_MIN)*(Float(p.x/self.width()))+VALENCE_MIN
    }
}
