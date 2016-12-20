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
    
    @IBOutlet weak var lbEnergy: UILabel!
    @IBOutlet weak var imgFace: UIImageView!
    
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
        updateStatus()
    }
    
    func setDotPosition(_ p: CGPoint) {
        previousPosition = p
        dot.setCenter(newCenter: p)
        
        energy = (ENERGY_MAX-ENERGY_MIN)*(Float(p.y/self.height()))+ENERGY_MIN
        valence = (VALENCE_MAX-VALENCE_MIN)*(Float(p.x/self.width()))+VALENCE_MIN
        updateStatus()
    }
    
    func updateStatus() {
        let eScale = (Constants.Defaults.energyMax - Constants.Defaults.energyMin)/3
        let scale1 = Constants.Defaults.energyMin + eScale
        let scale2 = Constants.Defaults.energyMax - eScale;
        
        if (energy < scale1) {
            lbEnergy.text = "Low"
            lbEnergy.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else if (energy > scale2) {
            lbEnergy.text = "High"
            lbEnergy.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        } else {
            lbEnergy.text = "Medium"
            lbEnergy.textColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        }
        
        let vScale = (Constants.Defaults.valenceMax - Constants.Defaults.valenceMin)/3
        let scale3 = Constants.Defaults.valenceMin + vScale
        let scale4 = Constants.Defaults.valenceMax - vScale;
       
        if (valence < scale3) {
            imgFace.image = #imageLiteral(resourceName: "Happiness0")
        } else if (valence > scale4) {
            imgFace.image = #imageLiteral(resourceName: "Happiness2")
        } else {
            imgFace.image = #imageLiteral(resourceName: "Happiness1")
        }
    }
}
