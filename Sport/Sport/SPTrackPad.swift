//
//  SPTrackPad.swift
//  Sport
//
//  Created by Tien on 6/12/16.
//  Copyright © 2016 tiennth. All rights reserved.
//

import UIKit

class SPTrackPad: UIControl {
    //var emitter: CAEmitterLayer!
    
    let ENERGY_MAX: Float = 1.0
    let ENERGY_MIN: Float = 0.0
    
    let VALENCE_MAX: Float = 1.0
    let VALENCE_MIN: Float = -1.0
    
    let EMITTER_SIZE = CGSize(width: 20, height: 20)
    
    var usableVerticalLength: CGFloat = 0
    var usableHorizontalLength: CGFloat = 0
    
    // TODO:
    var previousPosition: CGPoint = CGPoint(x: 1, y: 1)
    
    var valence: Float = 0
    var energy: Float = 0.5
    
    var dot: UIImageView!
    
    override func awakeFromNib() {
        commonInit()
        
        
        dot = UIImageView.init(image: #imageLiteral(resourceName: "dot"))
        self.addSubview(dot)
        
        
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
    
    func setDotPosition(_ p: CGPoint) {
        previousPosition = p
        dot.setCenter(newCenter: p)
        
        energy = (ENERGY_MAX-ENERGY_MIN)*(Float(p.y/self.height()))+ENERGY_MIN
        valence = (VALENCE_MAX-VALENCE_MIN)*(Float(p.x/self.width()))+VALENCE_MIN
    }
    
    
    
    internal override class var layerClass : AnyClass {
        return CAEmitterLayer.self
    }
}
