//
//  TiltCalculator.swift
//  FootNoter
//
//  Created by StudentAcct on 2/8/20.
//  Copyright © 2020 Sammmo. All rights reserved.
//

import Foundation

struct Calibration { //TODO: this should be a core data managed object
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

struct Tilt2 {
    var result: Double
    
    init(x: Double, y: Double, z: Double, calibration: Calibration) {
        
        result = (180.0 * acos( ((calibration.x * x) + (calibration.y * y) + calibration.z * z) / (sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) ))) / Double.pi
    }
    //float inclination = 180.0*acos( (ax0*ax + ay0*ay + az0*az)/sqrt( (ax*ax + ay*ay + az*az)*(ax0*ax0 + ay0*ay0 + az0*az0)))/M_PI;
}

struct Tilt3 {
    var pitch: Double
    var yaw: Double
    
    init(ax: Double, ay: Double, az: Double) {
        pitch = atan(ax / (sqrt( pow(ay, 2) + pow(az, 2)))) * (180 / Double.pi)
        yaw = atan2(ax, ay)*(180 / Double.pi)
    }
}

struct OTScalc {
    var angle1: Double
    var angle2: Double
    
    init(x: Double, y: Double, z: Double, orientation: String?) {
        //TODO: Orientation
        angle1 = abs(atan2(y, (pow(x, 2) + pow(z, 2)).squareRoot())) * (180 / Double.pi)
        angle2 = abs(acos(z) * 180.0 / Double.pi)
    }
}

/*struct TiltCalculationV2 {
    var roll: Double
    var yaw: Double
    let alpha = 0.5
    
    init(x: Double, y: Double, z: Double) {
        let xVal = x * alpha
        let xFilter = (xVal * (1.0 - alpha))
        let yVal = y * alpha
        let yFilter = (yVal * (1.0 - alpha))
        let zVal = z * alpha
        let zFilter = (zVal * (1.0 - alpha))
        
        //roll = (atan(-yFilter, zFilter)*180/Double.pi)
    }
    
    
}*/

struct TrigCalc {
    var angle: Double
    
    init(z: Double) {
        self.angle = acos(z) * 180.0 / Double.pi
    }
}
