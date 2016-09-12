//
//  SPTrackPad.swift
//  Sport
//
//  Created by Tien on 6/12/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SPTrackPad: UIControl {
    var emitter: CAEmitterLayer!
    
    let ENERGY_MAX: Float = 1.0
    let ENERGY_MIN: Float = 0.0
    
    let VALENCE_MAX: Float = 1.0
    let VALENCE_MIN: Float = -1.0
    
    let EMITTER_SIZE = CGSize(width: 10, height: 10)
    
    var usableVerticalLength: CGFloat = 0
    var usableHorizontalLength: CGFloat = 0
    
    var previousPosition: CGPoint = CGPointZero
    
    var valence: Float = 0
    var energy: Float = 0.5
    
    override func awakeFromNib() {
        commonInit()
        
        emitter = self.layer as! CAEmitterLayer
        emitter.emitterSize = CGSize(width: 10, height: 10)
        emitter.emitterShape = kCAEmitterLayerRectangle
        
        let fire = CAEmitterCell()
        fire.birthRate = 0
        fire.lifetime = 3.0
        fire.lifetimeRange = 0.5
        fire.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.1).CGColor
        fire.contents = UIImage(named: "Particles_fire")?.CGImage
        fire.name = "fire"
        fire.velocity = 10
        fire.velocityRange = 20
        fire.emissionRange = CGFloat(M_PI_2)
        fire.scaleSpeed = 0.3;
        fire.spin = 0.5;
        
        emitter.renderMode = kCAEmitterLayerAdditive;
        emitter.emitterCells = [fire]
        
        emitter.emitterPosition = CGPointZero
        valence = VALENCE_MIN
        energy = ENERGY_MAX
    }
    
    func commonInit() {
        usableHorizontalLength = bounds.size.width - EMITTER_SIZE.width
        usableVerticalLength = bounds.size.height - EMITTER_SIZE.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        commonInit()
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
        let currentRect = CGRect(origin: emitter.emitterPosition, size: CGSize(width: 20, height: 20))
        previousPosition = touchPoint
        
        if CGRectContainsPoint(currentRect, touchPoint) {
            setEmitting(true)
            return true
        }
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let touchPosition = touch.locationInView(self)
        
        let verticalDelta = previousPosition.y - touchPosition.y // Energy max value is top, but the positionY in coordinate is top-down.
        let horizontalDelta = touchPosition.x - previousPosition.x
        let valenceDelta = (VALENCE_MAX - VALENCE_MIN) * Float(horizontalDelta / usableHorizontalLength)
        let energyDelta = (ENERGY_MAX - ENERGY_MIN) * Float(verticalDelta / usableVerticalLength)
        var newValence = valence + valenceDelta
        var newEnergy = energy + energyDelta
        
        if newValence > VALENCE_MAX {
            newValence = VALENCE_MAX
        } else if newValence < VALENCE_MIN {
            newValence = VALENCE_MIN
        }
        valence = newValence
        
        if newEnergy > ENERGY_MAX {
            newEnergy = ENERGY_MAX
        } else if newEnergy < ENERGY_MIN {
            newEnergy = ENERGY_MIN
        }
        energy = newEnergy
        print("Valence: \(valence) --- Energy: \(energy)")
        
        previousPosition = touchPosition
        
        emitter.emitterPosition = touch.locationInView(self)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        print("End tracking")
        sendActionsForControlEvents(.ValueChanged)
//        setEmitting(false)
    }
    
    func setEmitting(isEmitting: Bool) {
        emitter.setValue(NSNumber.init(integer: isEmitting ? 200 : 0), forKeyPath: "emitterCells.fire.birthRate")
    }
    
    
    
    internal override class func layerClass() -> AnyClass {
        return CAEmitterLayer.self
    }
}
