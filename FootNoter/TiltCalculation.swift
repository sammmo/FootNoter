//
//  TiltCalculator.swift
//  FootNoter
//
//  Created by StudentAcct on 2/8/20.
//  Copyright © 2020 Sammmo. All rights reserved.
//

import Foundation

struct Calibration {
    var x: Double
    var y: Double
    var z: Double
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct TiltCalculation {
    var resultantXAngle: Double
    var resultantYAngle: Double
    
    init(x: Double, y: Double, z: Double, calib: Calibration) {
        //get deviation of each axis from baseline
        let xDev = calib.x - x
        let yDev = calib.y - y
        let zDev = calib.z - z
        
        //square the values
        let x2 = pow(xDev, 2)
        let y2 = pow(yDev, 2)
        let z2 = pow(zDev, 2)
        
        //Determine x angle
        let resultX = xDev / sqrt(y2 + z2)
        self.resultantXAngle = atan(resultX)
        
        //Determine y angle
        let resultY = yDev / sqrt(x2 + z2)
        self.resultantYAngle = atan(resultY)
    }
}
